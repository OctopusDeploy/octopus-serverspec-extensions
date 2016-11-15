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

    def initialize(serverUrl, apiKey)
      @name = "Octopus Deploy Tentacle"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      url = "#{serverUrl}/api/machines/all?api-key=#{apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      @body = JSON.parse(resp.body)
      thumbprint = `"c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe" --console --show-thumbprint --nologo --thumbprint-only`.strip
      @machine = @body.select {|e| e["Thumbprint"] == thumbprint}.first
    end

    def registered_with_the_server?
      !@machine.nil?
    end

    def online?
      @machine["Status"] == "Online"
    end

    def in_environment?(environment_name)
      url = "#{@serverUrl}/api/environments/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      environments = JSON.parse(resp.body)
      environment_id = environments.select {|e| e["Name"] == environment_name}.first["Id"]
      !@machine["EnvironmentIds"].select {|e| e == environment_id}.nil?
    end

    def has_role?(role_name)
      roles = @machine["Roles"]
      !roles.select {|e| e == role_name}.nil?
    end
  end

  def octopus_deploy_tentacle(serverUrl, apiKey)
    OctopusDeployTentacle.new(serverUrl, apiKey)
  end
end

include Serverspec::Type