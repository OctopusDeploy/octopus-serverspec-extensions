require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployTentacle < Base
    @machine = nil
    @serverUrl = nil
    @apiKey = nil
    @serverSupportsSpaces = nil
    @spaceId = nil
    @spaceFragment = ""

    def initialize(serverUrl, apiKey, instance, spaceId = 'Spaces-1')
      @name = "Octopus Deploy Tentacle #{instance}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey
      @spaceId = spaceId

      if (serverUrl.nil?)
        puts "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
        return
      end
      if (apiKey.nil?)
        puts "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
        return
      end

      if (exists?)
        thumbprint = `"c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe" show-thumbprint --console --nologo --instance #{instance}`
        thumbprint = thumbprint.gsub('==== ShowThumbprintCommand starting ====', '').strip
        thumbprint = thumbprint.gsub('The thumbprint of this Tentacle is: ', '').strip
        thumbprint = thumbprint.gsub('==== ShowThumbprintCommand completed ====', '').strip
        thumbprint = thumbprint.gsub('==== ShowThumbprintCommand ====', '').strip

        @serverSupportsSpaces = check_supports_spaces(serverUrl)

        if (@serverSupportsSpaces)
          @spaceFragment = "#{@spaceId}/"
        end

        @machine = get_machine_via_api(serverUrl, apiKey, thumbprint)
      else
        puts "tentacle.exe does not exist"
      end
    end

    def registered_with_the_server?
      !@machine.nil?
    end

    def online?
      return nil if @machine.nil?
      @machine = poll_until_machine_has_completed_healthcheck(@serverUrl, @apiKey, @machine["Thumbprint"])
      status = @machine['Status']
      if ("#{status}" == "")
        status = @machine['HealthStatus'] if "#{status}" == ""
        puts "Expected status 'Healthy|HasWarnings' for Tentacle #{@name}, but got '#{status}'" if (status != "Healthy" && status != "HasWarnings")
        status == "Healthy" || status == "HasWarnings"
      else
        puts "Expected status 'Online|CalamariNeedsUpgrade|NeedsUpgrade' for Tentacle #{@name}, but got '#{status}'" if (status != "Online" && status != "CalamariNeedsUpgrade" && status != "NeedsUpgrade")
        status == "Online" || status == "CalamariNeedsUpgrade" || status == "NeedsUpgrade"
      end
    end

    def in_environment?(environment_name)
      return false if @machine.nil?
      url = "#{@serverUrl}/api/#{@spaceFragment}environments/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      environments = JSON.parse(resp.body)
      environment_id = environments.select {|e| e["Name"] == environment_name}.first["Id"]
      !@machine["EnvironmentIds"].select {|e| e == environment_id}.empty?
    end

    def in_space?(space_name)
      return false if @machine.nil?
      return false if @serverSupportsSpaces
      url = "#{@serverUrl}/api/#{@spaceFragment}spaces/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      spaces = JSON.parse(resp.body)
      space_id = spaces.select {|e| e["Name"] == space_name}.first["Id"]
      @machine["SpaceId"] == space_id
    end

    def has_tenant?(tenant_name)
      return false if @machine.nil?
      url = "#{@serverUrl}/api/#{@spaceFragment}tenants/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      tenants = JSON.parse(resp.body)
      tenant_id = tenants.select {|e| e["Name"] == tenant_name}.first["Id"]
      !@machine["TenantIds"].select {|e| e == tenant_id}.empty?
    end

    def has_tenant_tag?(tag_set, tag)
      return false if @machine.nil?
      tenant_tags = @machine["TenantTags"]
      !tenant_tags.select {|e| e == "#{tag_set}/#{tag}"}.empty?
    end

    def has_policy?(policy_name)
      return false if @machine.nil?
      url = "#{@serverUrl}/api/#{@spaceFragment}machinepolicies/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      policies = JSON.parse(resp.body)
      policy_id = policies.select {|e| e["Name"] == policy_name}.first["Id"]
      @machine["MachinePolicyId"] == policy_id
    end

    def has_role?(role_name)
      return false if @machine.nil?
      roles = @machine["Roles"]
      !roles.select {|e| e == role_name}.empty?
    end

    def has_display_name?(name)
      return false if @machine.nil?
      @machine["Name"] == name
    end

    def has_endpoint?(uri)
      return false if @machine.nil?
      puts "Expected uri '#{uri}' for Tentacle #{@name}, but got '#{@machine["Uri"]}'" unless (@machine["Uri"].casecmp(uri) == 0)
      @machine["Uri"].casecmp(uri) == 0
    end

    def has_tenanted_deployment_participation?(mode)
      return false if @machine.nil?
      @machine["TenantedDeploymentParticipation"] == mode
    end

    def listening_tentacle?
      return false if @machine.nil?
      puts "Expected CommunicationStyle 'TentaclePassive' for Tentacle #{@name}, but got '#{@machine["Endpoint"]["CommunicationStyle"]}'" if (@machine["Endpoint"]["CommunicationStyle"] != "TentaclePassive")
      @machine["Endpoint"]["CommunicationStyle"] == "TentaclePassive"
    end

    def polling_tentacle?
      return false if @machine.nil?
      puts "Expected CommunicationStyle 'TentacleActive' for Tentacle #{@name}, but got '#{@machine["Endpoint"]["CommunicationStyle"]}'" if (@machine["Endpoint"]["CommunicationStyle"] != "TentacleActive")
      @machine["Endpoint"]["CommunicationStyle"] == "TentacleActive"
    end

    def exists?
      ::File.exists?("c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe")
    end
  end

  def octopus_deploy_tentacle(serverUrl, apiKey, instance)
    OctopusDeployTentacle.new(serverUrl, apiKey, instance)
  end

  private

  def check_supports_spaces(serverUrl)
    begin
      resp = Net::HTTP.get_response(URI.parse("#{serverUrl}/api/"))
      body = JSON.parse(resp.body)
      version = body['Version']
      return Gem::Version.new(version) > Gem::Version.new('2019.0.0')
    rescue => e
      puts "Unable to connect to #{serverUrl}: #{e}"
    end

    return false
  end

  def poll_until_machine_has_completed_healthcheck(serverUrl, apiKey, thumbprint)
    machine = nil
    url = "#{serverUrl}/api/#{@spaceFragment}machines/all?api-key=#{apiKey}"

    now = Time.now
    counter = 1
    loop do
      machine = get_machine_via_api(serverUrl, apiKey, thumbprint)

      break if machine.nil?
      break if counter > 10
      break if !machine_healthcheck_outstanding(machine)
      puts "Machine health check for #{machine["Name"]} has not yet completed. Waiting 5 seconds to try again."
      counter += 1
      sleep 5
    end

    machine
  end

  def machine_healthcheck_outstanding(machine)
    machine["StatusSummary"] == "This machine was recently added. Please perform a health check."
  end

  def get_machine_via_api(serverUrl, apiKey, thumbprint)
    machine = nil
    url = "#{serverUrl}/api/#{@spaceFragment}machines/all?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      machine = body.select {|e| e["Thumbprint"] == thumbprint}.first unless body.nil?
    rescue => e
      puts "Unable to connect to #{url}: #{e}"
    end

    machine
  end
end

include Serverspec::Type
