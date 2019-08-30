require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployUpgradeConfig < Base
    @serverUrl = nil
    @apiKey = nil
    @upgradeConfig = nil

    @NotificationModes = ['AlwaysShow', 'ShowOnlyMajorMinor', 'NeverShow']

    def initialize(*url_and_api_key)
      serverUrl, apiKey = get_octopus_creds(url_and_api_key)

      @name = "Octopus Deploy Upgrade Config #{serverUrl}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      # is it still nil?
      if serverUrl.nil?
        raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if apiKey.nil?
        raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
      end

      @upgradeConfig = get_upgrade_config_via_api(serverUrl, apiKey)
    end

    def has_notification_mode?(mode)
      false if @upgradeConfig.nil?
      @upgradeConfig['NotificationMode'] == mode
    end

    def never_show_notifications?
      false if @upgradeConfig.nil?
      has_notification_mode?('NeverShow')
    end

    def always_show_notifications?
      false if @upgradeConfig.nil?
      has_notification_mode?('AlwaysShow')
    end

    def show_major_minor_notifications?
      false if @upgradeConfig.nil?
      has_notification_mode?('ShowOnlyMajorMinor')
    end

    def include_statistics?
      false if @upgradeConfig.nil?
      @upgradeConfig['IncludeStatistics'] == true
    end

    def allow_checking?
      false if @upgradeConfig.nil?
      @upgradeConfig['AllowChecking'] == true
    end
  end

  # module-level constructors/entrypoints

  def octopus_deploy_upgrade_config(*url_and_api_key)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)
    OctopusDeployUpgradeConfig.new(serverUrl, apiKey)
  end

  def octopus_upgrade_config(*url_and_api_key)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)
    octopus_deploy_upgrade_config(serverUrl, apiKey)
  end

  private

  def get_upgrade_config_endpoint(serverUrl)
    endpoint = nil

    url = "#{serverUrl}/api/"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      json = body unless body.nil?
      endpoint = json['Links']['UpgradeConfiguration']
    rescue => e
      raise "get_upgrade_config_endpoint: Unable to connect to #{url}: #{e}"
    end

    endpoint
  end

  def get_upgrade_config_via_api(serverUrl, apiKey)
    smtp = nil

    stem = get_upgrade_config_endpoint(serverUrl)
    url = "#{serverUrl}#{stem}?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      smtp = body unless body.nil?
    rescue => e
      raise "get_upgrade_config_via_api: Unable to connect to #{url}: #{e}"
    end

    smtp
  end
end

include Serverspec::Type
