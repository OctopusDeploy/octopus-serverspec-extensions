require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployTentacle < Base
    @machine = nil
    @serverUrl = nil
    @apiKey = nil

    def initialize(serverUrl, apiKey, instance)
      @name = "Octopus Deploy Tentacle #{instance}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if (serverUrl.nil?)
        puts "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
        return
      end
      if (apiKey.nil?)
        puts "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
        return
      end

      if (exists?)
        thumbprint = `"c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe" --console --show-thumbprint --nologo --instance #{instance}`.strip.gsub('The thumbprint of this Tentacle is: ', '')
        @machine = get_machine_via_api(serverUrl, apiKey, thumbprint)
      end
    end

    def registered_with_the_server?
      !@machine.nil?
    end

    def online?
      return nil if @machine.nil?
      @machine = poll_until_machine_has_completed_healthcheck(@serverUrl, @apiKey, @machine["Thumbprint"])
      puts "Expected status 'Online|CalamariNeedsUpgrade|NeedsUpgrade' for Tentacle #{@name}, but got '#{@machine["Status"]}'" if (@machine["Status"] != "Online" && @machine["Status"] != "CalamariNeedsUpgrade")
      @machine["Status"] == "Online" || @machine["Status"] == "CalamariNeedsUpgrade" || @machine["Status"] == "NeedsUpgrade"
    end

    def in_environment?(environment_name)
      return false if @machine.nil?
      url = "#{@serverUrl}/api/environments/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      environments = JSON.parse(resp.body)
      environment_id = environments.select {|e| e["Name"] == environment_name}.first["Id"]
      !@machine["EnvironmentIds"].select {|e| e == environment_id}.empty?
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

    def listening_tentacle?
      return false if @machine.nil?
      puts "Expected CommunicationStyle 'TentaclePassive' for Tentacle #{@name}, but got '#{@machine["EndPoint"]["CommunicationStyle"]}'" if (@machine["EndPoint"]["CommunicationStyle"] != "TentaclePassive")
      @machine["EndPoint"]["CommunicationStyle"] == "TentaclePassive"
    end

    def polling_tentacle?
      return false if @machine.nil?
      puts "Expected CommunicationStyle 'TentacleActive' for Tentacle #{@name}, but got '#{@machine["EndPoint"]["CommunicationStyle"]}'" if (@machine["EndPoint"]["CommunicationStyle"] != "TentacleActive")
      @machine["EndPoint"]["CommunicationStyle"] == "TentacleActive"
    end

    def exists?
      ::File.exists?("c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe")
    end
  end

  def octopus_deploy_tentacle(serverUrl, apiKey, instance)
    OctopusDeployTentacle.new(serverUrl, apiKey, instance)
  end

  private

  def poll_until_machine_has_completed_healthcheck(serverUrl, apiKey, thumbprint)
    machine = nil
    url = "#{serverUrl}/api/machines/all?api-key=#{apiKey}"

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
    url = "#{serverUrl}/api/machines/all?api-key=#{apiKey}"

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