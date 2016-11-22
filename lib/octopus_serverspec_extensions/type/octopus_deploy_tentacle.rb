require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployTentacle < Base
    @body = nil
    @machine = nil
    @serverUrl = nil
    @apiKey = nil

    def initialize(serverUrl, apiKey, instance)
      @name = "Octopus Deploy Tentacle"
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

      url = "#{serverUrl}/api/machines/all?api-key=#{apiKey}"
      begin
        resp = Net::HTTP.get_response(URI.parse(url))
        @body = JSON.parse(resp.body)
        if (instance.nil?)
          thumbprint = `"c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe" --console --show-thumbprint --nologo`.strip.gsub('The thumbprint of this Tentacle is: ', '')
        else
          @name = instance
          thumbprint = `"c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe" --console --show-thumbprint --nologo --instance #{instance}`.strip.gsub('The thumbprint of this Tentacle is: ', '')
        end
        @machine = @body.select {|e| e["Thumbprint"] == thumbprint}.first
      rescue => e
        puts "Unable to connect to #{url}"
      end
    end

    def registered_with_the_server?
      !@machine.nil?
    end

    def online?
      return nil if @machine.nil?
      puts "Expected status 'Online' or 'CalamariNeedsUpgrade', but got '#{@machine["Status"]}'" if (@machine["Status"] != "Online" && @machine["Status"] != "CalamariNeedsUpgrade")
      @machine["Status"] == "Online" || @machine["Status"] == "CalamariNeedsUpgrade"
    end

    def in_environment?(environment_name)
      return false if @machine.nil?
      url = "#{@serverUrl}/api/environments/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      environments = JSON.parse(resp.body)
      environment_id = environments.select {|e| e["Name"] == environment_name}.first["Id"]
      !@machine["EnvironmentIds"].select {|e| e == environment_id}.nil?
    end

    def has_role?(role_name)
      return false if @machine.nil?
      roles = @machine["Roles"]
      !roles.select {|e| e == role_name}.nil?
    end

    def listening_tentacle?
      return false if @machine.nil?
      puts "Expected CommunicationStyle 'TentaclePassive', but got '#{@machine["EndPoint"]["CommunicationStyle"]}'" if (@machine["EndPoint"]["CommunicationStyle"] != "TentaclePassive")
      @machine["EndPoint"]["CommunicationStyle"] == "TentaclePassive"
    end

    def polling_tentacle?
      return false if @machine.nil?
      puts "Expected CommunicationStyle 'TentacleActive', but got '#{@machine["EndPoint"]["CommunicationStyle"]}'" if (@machine["EndPoint"]["CommunicationStyle"] != "TentacleActive")
      @machine["EndPoint"]["CommunicationStyle"] == "TentacleActive"
    end
  end

  def octopus_deploy_tentacle(serverUrl, apiKey, instance)
    OctopusDeployTentacle.new(serverUrl, apiKey, instance)
  end
end

include Serverspec::Type