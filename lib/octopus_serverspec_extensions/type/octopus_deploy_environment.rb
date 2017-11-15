require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployEnvironment < Base
    @environment = nil
    @serverUrl = nil
    @apiKey = nil

    def initialize(serverUrl, apiKey, environment_name)
      @name = "Octopus Deploy Environment #{environment_name}"
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

      @environment = get_environment_via_api(serverUrl, apiKey, environment_name)
    end

    def exists?
      !@environment.nil?
    end
  end

  def octopus_deploy_environment(serverUrl, apiKey, environment_name)
    OctopusDeployEnvironment.new(serverUrl, apiKey, environment_name)
  end

  private

  def get_environment_via_api(serverUrl, apiKey, environment_name)
    environment = nil
    url = "#{serverUrl}/api/environments?name=#{environment_name}&api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      environment = body['Items'].first unless body.nil?
    rescue => e
      puts "Unable to connect to #{url}: #{e}"
    end

    environment
  end
end

include Serverspec::Type