require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeploySmtpConfig < Base
    @serverUrl = nil
    @apiKey = nil

    if serverUrl.nil?
      raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
    end
    if apiKey.nil?
      raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
    end

    def is_configured?

    end

    def uses_ssl?

    end

    def is_on_port?(portnumber)

    end

    def is_on_host?(hostname)

    end

    def uses_credentials?(username)
      # we can't test the password, but we can check the username
    end

    def has_from_address?(fromaddress)

    end

    def octopus_deploy_smtp_config(serverUrl, apiKey)
      OctopusDeploySmtpConfig.new(serverUrl, apiKey)
    end

    def octopus_deploy_smtp_config
      # no endpoint and key supplied, get creds from the environment
      server_url = ENV['OCTOPUS_CLI_SERVER']
      api_key = ENV['OCTOPUS_CLI_API_KEY']

      OctopusDeploySmtpConfig.new(server_url, api_key)
    end

    private

    def get_smtp_config_via_api(serverUrl, apiKey, projectgroup_name)
      pg = nil
      url = "#{serverUrl}/smtpconfiguration?api-key=#{apiKey}"

      begin
        resp = Net::HTTP.get_response(URI.parse(url))
        body = JSON.parse(resp.body)
        smtp = body unless body.nil?
      rescue => e
        raise "get_smtp_config_via_api: Unable to connect to #{url}: #{e}"
      end

      smtp
    end

  end
end

include Serverspec::Type
