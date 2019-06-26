require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployAccount < Base
    @account = nil
    @accountName = nil
    @serverUrl = nil
    @apiKey = nil
    @serverSupportsSpaces = nil
    @spaceId = nil
    @spaceFragment = ""


    # constants for account types
    AZURE = 'AzureSubscription'.freeze
    AWS = 'AmazonWebServicesAccount'.freeze
    SSH = 'SshKeypair'.freeze
    TOKEN = 'Token'.freeze
    USERNAME = 'UsernamePassword'.freeze
    ACCOUNT_TYPES = [AZURE, AWS, SSH, TOKEN, USERNAME]

    def initialize(*url_and_api_key, account_name)
      server_url, api_key = get_octopus_creds(url_and_api_key)

      @serverSupportsSpaces = check_supports_spaces(server_url)

      @name = "Octopus Deploy Account #{account_name}"
      @runner = Specinfra::Runner
      @accountName = account_name
      @serverUrl = server_url
      @apiKey = api_key

      if account_name.nil? or account_name == ""
        raise "'account_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end
    end

    def exists?
      load_resource_if_nil()
      (!@account.nil?) && (@account != [])
    end

    def has_description?(account_description)
      load_resource_if_nil()
      return false if @account.nil?
      @account["Description"] == account_description  # this seems to be case sensitive. Is that good?
    end

    def account_type?(account_type_name)
      load_resource_if_nil()
      if !ACCOUNT_TYPES.include? account_type_name
        raise("'#{account_type_name}' is not a valid account type")
      end
      return false if @account.nil?

      @account["AccountType"] == account_type_name
    end

    def azure_account?
      return false if @account.nil?
      account_type?(AZURE)
      # should also have a subscription number, but Octopus manages validation on this
    end

    def aws_account?
      return false if @account.nil?
      account_type?(AWS)
    end

    def ssh_key_pair?
      return false if @account.nil?
      account_type?(SSH)
    end

    def username_password?
      return false if @account.nil?
      account_type?(USERNAME)
    end

    def token?
      return false if @account.nil?
      account_type?(TOKEN)
    end

    def in_environment?(environment_name)
      load_resource_if_nil()
      return false if @account.nil?
      url = "#{@serverUrl}/api/#{@spaceFragment}environments/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      environments = JSON.parse(resp.body)
      environment_id = environments.select {|e| e["Name"] == environment_name}.first["Id"]
      !@account["EnvironmentIds"].select {|e| e == environment_id}.empty?
    end

    def has_tenanted_deployment_participation?(mode)
      load_resource_if_nil()
      return false if @machine.nil?
      @machine["TenantedDeploymentParticipation"] == mode # copied directly from tentacle
    end

    def has_property?(property_name, expected_value)
      load_resource_if_nil()
      return false if @account.nil?
      @account[property_name] == expected_value
    end

    def in_space(space_name)
      # allows us to tag .in_space() onto the end of the resource. as in
      # describe octopus_account("account name").in_space("MyNewSpace") do
      @spaceId = get_space_id?(space_name)
      if @accountName.nil?
        raise "'account_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      self
    end

    private

    def load_resource_if_nil
      if @account.nil?
        @account = get_account_via_api(@serverUrl, @apiKey, @accountName)
      end
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

  def octopus_deploy_account(*url_and_api_key, account_name)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)

    OctopusDeployAccount.new(serverUrl, apiKey, account_name)
  end

  def octopus_account(*url_and_api_key, account_name)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)

    OctopusDeployAccount.new(serverUrl, apiKey, account_name)
  end

  private

  def get_account_via_api(serverUrl, apiKey, account_name)
    account = nil

    unless @spaceId.nil?
      # set the spaceId correctly
      @spaceFragment = "#{@spaceId}/"
    end

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


end

include Serverspec::Type
