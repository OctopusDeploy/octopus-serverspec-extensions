require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeploySmtpConfig < Base
    @serverUrl = nil
    @apiKey = nil
    @smtpConfig = nil

    def initialize(*url_and_api_key)
      serverUrl, apiKey = get_octopus_creds(url_and_api_key)

      @name = "Octopus Deploy SMTP Config #{serverUrl}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if serverUrl.nil?
        serverUrl = get_env_var('OCTOPUS_CLI_SERVER').chomp('/') # removes trailing slash if present
      end

      if apiKey.nil?
        apiKey = get_env_var('OCTOPUS_CLI_API_KEY')
      end

      # is it still nil?
      if serverUrl.nil?
        raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if apiKey.nil?
        raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
      end

      @smtpConfig = get_smtp_config_via_api(serverUrl, apiKey)
    end

    def configured?
      url = "#{@serverUrl}/api/smtpconfiguration/isconfigured?api-key=#{@apiKey}"
      begin
        resp = Net::HTTP.get_response(URI.parse(url))
        body = JSON.parse(resp.body)
        smtp = body unless body.nil?
      rescue => e
        raise "get_smtp_config_via_api: Unable to connect to #{url}: #{e}"
      end

      smtp["IsConfigured"]
    end

    def using_ssl?
      false if @smtpConfig.nil?
      @smtpConfig["EnableSsl"]
    end

    def on_port?(port_number)
      false if @smtpConfig.nil?
      @smtpConfig["SmtpPort"] == port_number
    end

    def on_host?(hostname)
      false if @smtpConfig.nil?
      @smtpConfig["SmtpHost"] == hostname
    end

    def using_credentials?(username)
      # we can't test the password, but we can check the username
      false if @smtpConfig.nil?
      @smtpConfig["SmtpLogin"] == username && @smtpConfig["SmtpPassword"]["HasValue"]
    end

    def has_from_address?(from_address)
      false if @smtpConfig.nil?
      @smtpConfig["SendEmailFrom"] == from_address
    end
  end

  def octopus_deploy_smtp_config(*url_and_api_key)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)
    OctopusDeploySmtpConfig.new(serverUrl, apiKey)
  end

  def octopus_smtp_config(*url_and_api_key)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)
    octopus_deploy_smtp_config(serverUrl, apiKey)
  end

  private

  def get_smtp_config_via_api(serverUrl, apiKey)
    smtp = nil

    url = "#{serverUrl}/api/smtpconfiguration?api-key=#{apiKey}"

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

include Serverspec::Type
