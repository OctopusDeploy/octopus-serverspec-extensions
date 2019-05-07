require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployAccount < Base
    @target = nil
    @serverUrl = nil
    @apiKey = nil
    @serverSupportsSpaces = nil
    @spaceId = nil
    @spaceFragment = ""

    def initialize(serverUrl, apiKey, account_name, spaceID = 'Spaces-1')
      @name = "Octopus Deploy Account #{account_name}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey
      @spaceId = spaceID

      if (serverUrl.nil?)
        raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if (apiKey.nil?)
        raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if (account_name.nil?)
        raise "'account_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end

      @serverSupportsSpaces = check_supports_spaces(serverUrl)

      if (@serverSupportsSpaces)
        @spaceFragment = "#{@spaceId}/"
      end

      @account = get_account_via_api(serverUrl, apiKey, account_name)
    end

    def exists?
      (!@account.nil?) && (@account != [])
    end

    def is_azure_account?
      return false if @account.nil?
      @account["AccountType"] == "AzureSubscription"
    end

    def is_aws_account?
      return false if @account.nil?
      @account["AccountType"] == "AmazonWebServicesAccount"
    end

    def in_space?(space_name)
      return false if @account.nil?
      return false if @serverSupportsSpaces
      url = "#{@serverUrl}/api/#{@spaceFragment}spaces/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      spaces = JSON.parse(resp.body)
      space_id = spaces.select {|e| e["Name"] == space_name}.first["Id"]
      @machine["SpaceId"] == space_id
    end
  end

  def octopus_deploy_account(serverUrl, apiKey, account_name)
    OctopusDeployAccount.new(serverUrl, apiKey, account_name)
  end

  private

  def get_account_via_api(serverUrl, apiKey, account_name)
    account = nil
    url = "#{serverUrl}/api/#{@spaceFragment}accounts/all?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      account = body.select {|i| i['Name'] == account_name } unless body.nil?
    rescue => e
      raise "get_account_via_api: Unable to connect to #{url}: #{e}"
    end

    account
  end

  def check_supports_spaces(serverUrl)
    begin
      resp = Net::HTTP.get_response(URI.parse("#{serverUrl}/api/"))
      body = JSON.parse(resp.body)
      version = body['Version']
      return Gem::Version.new(version) > Gem::Version.new('2019.0.0')
    rescue => e
      puts "check_supports_spaces: Unable to connect to #{serverUrl}: #{e}"
    end

    return false
  end

end

include Serverspec::Type
