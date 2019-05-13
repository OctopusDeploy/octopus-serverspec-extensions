require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployAccount < Base
    @account = nil
    @serverUrl = nil
    @apiKey = nil
    @serverSupportsSpaces = nil
    @spaceId = nil
    @spaceFragment = ""

    AZURE = 'AzureSubscription'.freeze
    AWS = 'AmazonWebServicesAccount'.freeze
    SSH = 'SshKeypair'.freeze
    TOKEN = 'Token'.freeze
    USERNAME = 'UsernamePassword'.freeze

    def initialize(serverUrl, apiKey, account_name, space_name = nil)
      @name = "Octopus Deploy Account #{account_name}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if serverUrl.nil?
        raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if apiKey.nil?
        raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if account_name.nil?
        raise "'account_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end

      @serverSupportsSpaces = check_supports_spaces(serverUrl)

      if @serverSupportsSpaces
        # set the spaceId correctly

        if space_name.nil?
          @spaceId = 'Spaces-1' # default to Spaces-1
        else
          @spaceId = get_space_id?(space_name)
        end

        @spaceFragment = "#{@spaceId}/"
      end

      @account = get_account_via_api(serverUrl, apiKey, account_name)
    end

    def exists?
      (!@account.nil?) && (@account != [])
    end

    def has_description?(account_description)
      return false if @account.nil?
      @account["Description"] == account_description
    end

    def is_account_type?(account_type_name)
      accounttypes = ['SshKeyPair', 'UsernamePassword', 'AzureSubscription', 'Token', 'AmazonWebServicesAccount']
      if !accounttypes.include? account_type_name
        raise("'#{account_type_name}' is not a valid account type")
      end
      return false if @account.nil?

      @account["AccountType"] == account_type_name
    end

    def is_azure_account?
      return false if @account.nil?
      @account["AccountType"] == "AzureSubscription"
      # should also have a subscription number, but Octopus manages validation on this
    end

    def is_aws_account?
      return false if @account.nil?
      @account["AccountType"] == "AmazonWebServicesAccount"
    end

    def is_ssh_key_pair?

    end

    def is_username_password?

    end

    def is_token?

    end

    def in_environment?(environment_name)
      return false if @account.nil?
      url = "#{@serverUrl}/api/#{@spaceFragment}environments/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      environments = JSON.parse(resp.body)
      environment_id = environments.select {|e| e["Name"] == environment_name}.first["Id"]
      !@account["EnvironmentIds"].select {|e| e == environment_id}.empty?
    end

    def has_tenant_mode?(tenant_mode)

    end

    def has_property?(property_name, expected_value)
      return false if @account.nil?
      @account[property_name] == expected_value
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
      account = body.select {|i| i['Name'] == account_name }.first unless body.nil?
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

    false
  end

  def get_space_id?(space_name)
    return false if @serverSupportsSpaces.nil?
    url = "#{@serverUrl}/api/Spaces/all?api-key=#{@apiKey}"
    resp = Net::HTTP.get_response(URI.parse(url))
    spaces = JSON.parse(resp.body)
    space_id = spaces.select {|e| e["Name"] == space_name}.first["Id"]
    space_id
  end

end

include Serverspec::Type
