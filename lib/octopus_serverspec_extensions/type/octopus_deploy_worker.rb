require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployWorker < Base
    @worker = nil
    @worker_name = nil
    @worker_thumbprint = nil
    @serverUrl = nil
    @apiKey = nil
    @serverSupportsSpaces = nil
    @spaceId = nil
    @spaceFragment = ""

    def initialize(*url_and_api_key, instance)
      serverUrl, apiKey = get_octopus_creds(url_and_api_key)

      @worker_name = instance

      @name = "Octopus Deploy Worker #{instance}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if (serverUrl.nil?)
        raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if (apiKey.nil?)
        raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
      end

      if (exists?)
        thumbprint = `"c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe" show-thumbprint --console --nologo --instance #{instance}`
        thumbprint = thumbprint.gsub('==== ShowThumbprintCommand starting ====', '').strip
        thumbprint = thumbprint.gsub('The thumbprint of this Tentacle is: ', '').strip
        thumbprint = thumbprint.gsub('==== ShowThumbprintCommand completed ====', '').strip
        thumbprint = thumbprint.gsub('==== ShowThumbprintCommand ====', '').strip

        @serverSupportsSpaces = check_supports_spaces(serverUrl)

        @worker_thumbprint = thumbprint
      else
        raise "tentacle.exe does not exist"
      end
    end

    def registered_with_the_server?
      load_resource_if_nil
      !@worker.nil?
    end

    def online?
      load_resource_if_nil
      return nil if @worker.nil?
      @worker = poll_until_worker_has_completed_healthcheck(@serverUrl, @apiKey, @worker["Thumbprint"])
      status = @worker['Status']
      if ("#{status}" == "")
        status = @worker['HealthStatus'] if "#{status}" == ""
        puts "Expected status 'Healthy|HasWarnings' for Worker #{@name}, but got '#{status}'" if (status != "Healthy" && status != "HasWarnings")
        status == "Healthy" || status == "HasWarnings"
      else
        puts "Expected status 'Online|CalamariNeedsUpgrade|NeedsUpgrade' for Worker #{@name}, but got '#{status}'" if (status != "Online" && status != "CalamariNeedsUpgrade" && status != "NeedsUpgrade")
        status == "Online" || status == "CalamariNeedsUpgrade" || status == "NeedsUpgrade"
      end
    end

    def in_space?(space_name)
      load_resource_if_nil
      return false if @worker.nil?
      return false if @serverSupportsSpaces
      url = "#{@serverUrl}/api/spaces/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      spaces = JSON.parse(resp.body)
      space_id = spaces.select {|e| e["Name"] == space_name}.first["Id"]
      @worker["SpaceId"] == space_id
    end

    def has_policy?(policy_name)
      load_resource_if_nil
      return false if @worker.nil?
      url = "#{@serverUrl}/api/#{@spaceFragment}machinepolicies/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      policies = JSON.parse(resp.body)
      policy_id = policies.select {|e| e["Name"] == policy_name}.first["Id"]
      @worker["MachinePolicyId"] == policy_id
    end

    def has_display_name?(name)
      load_resource_if_nil
      return false if @worker.nil?
      @worker["Name"] == name
    end

    def has_endpoint?(uri)
      load_resource_if_nil
      return false if @worker.nil?
      return false if @worker["Uri"].nil? # polling tentacles have null endpoint. catch that.
      puts "Expected uri '#{uri}' for Worker #{@name}, but got '#{@worker["Uri"]}'" unless (@worker["Uri"].casecmp(uri) == 0)
      @worker["Uri"].casecmp(uri) == 0
    end

    def listening_worker?
      load_resource_if_nil
      return false if @worker.nil?
      puts "Expected CommunicationStyle 'TentaclePassive' for Tentacle #{@name}, but got '#{@worker["Endpoint"]["CommunicationStyle"]}'" if (@worker["Endpoint"]["CommunicationStyle"] != "TentaclePassive")
      @worker["Endpoint"]["CommunicationStyle"] == "TentaclePassive"
    end

    def polling_worker?
      load_resource_if_nil
      return false if @worker.nil?
      puts "Expected CommunicationStyle 'TentacleActive' for Tentacle #{@name}, but got '#{@worker["Endpoint"]["CommunicationStyle"]}'" if (@worker["Endpoint"]["CommunicationStyle"] != "TentacleActive")
      @worker["Endpoint"]["CommunicationStyle"] == "TentacleActive"
    end

    def exists?
      ::File.exists?("c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe")
    end

    def in_space(space_name)
      # allows us to tag .in_space() onto the end of the resource. as in
      # describe octopus_account("account name").in_space("MyNewSpace") do
      @spaceId = get_space_id(space_name)
      if @worker_name.nil?
        raise "'worker_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      self
    end

    private

    def get_space_id(space_name)
      return false if @serverSupportsSpaces.nil?
      url = "#{@serverUrl}/api/Spaces/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      spaces = JSON.parse(resp.body)
      space_id = spaces.select {|e| e["Name"] == space_name}.first["Id"]
      space_id
    end

    def load_resource_if_nil
      if @worker.nil?
        @worker = get_worker_via_api(@serverUrl, @apiKey, @worker_thumbprint)
      end
    end
  end

  def octopus_deploy_worker(*url_and_api_key, instance)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)
    OctopusDeployWorker.new(serverUrl, apiKey, instance)
  end

  def octopus_worker(*url_and_api_key, instance)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)
    OctopusDeployWorker.new(serverUrl, apiKey, instance)
  end

  private

  def poll_until_worker_has_completed_healthcheck(serverUrl, apiKey, thumbprint)
    worker = nil
    url = "#{serverUrl}/api/#{@spaceFragment}workers/all?api-key=#{apiKey}"

    now = Time.now
    counter = 1
    loop do
      worker = get_worker_via_api(serverUrl, apiKey, thumbprint)

      break if worker.nil?
      break if counter > 10
      break if !worker_healthcheck_outstanding(worker)
      puts "Machine health check for #{worker["Name"]} has not yet completed. Waiting 5 seconds to try again."
      counter += 1
      sleep 5
    end

    worker
  end

  def worker_healthcheck_outstanding(worker)
    worker["StatusSummary"] == "This machine was recently added. Please perform a health check."
  end

  def get_worker_via_api(serverUrl, apiKey, thumbprint)
    worker = nil

    unless @spaceId.nil?
      @spaceFragment = "#{@spaceId}/"
    end

    url = "#{serverUrl}/api/#{@spaceFragment}workers/all?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      worker = body.select {|e| e["Thumbprint"] == thumbprint}.first unless body.nil?
    rescue => e
      puts "Unable to connect to #{url}: #{e}"
    end

    worker
  end
end

include Serverspec::Type
