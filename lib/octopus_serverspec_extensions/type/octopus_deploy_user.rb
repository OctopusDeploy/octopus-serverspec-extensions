require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployUser < Base
    @serverUrl = nil
    @apiKey = nil
    @userAccount = nil

    def initialize(serverUrl, apiKey, userName)
      @name = "Octopus Deploy User Account #{serverUrl}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if(serverUrl.nil?)
        serverUrl = get_env_var('OCTOPUS_CLI_SERVER').chomp('/')
      end

      if(apiKey.nil?)
        apiKey = get_env_var('OCTOPUS_CLI_API_KEY')
      end

      # is it still nil?
      if (serverUrl.nil?)
        raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if (apiKey.nil?)
        raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
      end

      if(userName.nil?)
        raise "'userName' was not provided"
      end

      @userAccount = get_user_via_api(serverUrl, apiKey, userName)

    end

    def is_service_account?
      return false if @userAccount.nil?
      @userAccount['IsService'] == true
    end

    def exists?
      (!@userAccount.nil?) && (@userAccount != [])
    end

    def active?
      return false if @userAccount.nil?
      @userAccount['IsActive'] == true
    end

    def has_email?(email)
      return false if @userAccount.nil?
      @userAccount['EmailAddress'] == email
    end


    private

    def get_user_via_api(serverUrl, apiKey, user_name)
      pg = nil
      url = "#{serverUrl}/api/users/all?api-key=#{apiKey}"

      begin
        resp = Net::HTTP.get_response(URI.parse(url))
        body = JSON.parse(resp.body)
        users = body unless body.nil?
        user = users.select {|i| i['Username'] == user_name }.first unless users.nil?
      rescue => e
        raise "get_smtp_config_via_api: Unable to connect to #{url}: #{e}"
      end

      user
    end

  end
end

include Serverspec::Type