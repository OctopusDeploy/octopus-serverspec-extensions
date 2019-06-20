require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployEnvironment < Base
    @environment = nil
    @serverUrl = nil
    @apiKey = nil

    def initialize(*url_and_api_key, environment_name)
      serverUrl = get_octopus_url(url_and_api_key[0])
      apiKey = get_octopus_api_key(url_and_api_key[1])

      @name = "Octopus Deploy Environment #{environment_name}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if (serverUrl.nil?)
        raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if (apiKey.nil?)
        raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if (environment_name.nil?)
        raise "'environment_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end

      @environment = get_environment_via_api(serverUrl, apiKey, environment_name)
    end

    def exists?
      (!@environment.nil?) && (@environment != [])
    end
  end

  def octopus_deploy_environment(*url_and_api_key, environment_name)
    serverUrl = get_octopus_url(url_and_api_key[0])
    apiKey = get_octopus_api_key(url_and_api_key[1])

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
      raise "Unable to connect to #{url}: #{e}"
    end

    environment
  end
end

include Serverspec::Type
