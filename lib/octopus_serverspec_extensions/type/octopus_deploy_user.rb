require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployUser < Base
    @serverUrl = nil
    @apiKey = nil
    @userAccount = nil

    def initialize(*url_and_api_key, userName)
      serverUrl, apiKey = get_octopus_creds(url_and_api_key)

      @name = "Octopus Deploy User Account #{userName}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      # is our auth still nil?
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

    def service_account?
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

    def has_display_name?(name)
      return false if @userAccount.nil?
      @userAccount['DisplayName'] == name
    end

    def has_api_key?(purpose)
      # "/api/users/Users-61/apikeys{/id}{?skip,take}"
      return false if @userAccount.nil?

      user_api_key = nil
      user_id = @userAccount['Id']
      url = "#{@serverUrl}/api/users/#{user_id}/apikeys?api-key=#{@apiKey}&take=200"

      begin
        resp = Net::HTTP.get_response(URI.parse(url))
        body = JSON.parse(resp.body)
        keys = body unless body.nil?
        user_api_key = keys['Items'].select {|i| i['Purpose'] == purpose }.first unless keys.nil?

        rescue => e
          raise "has_api_key: Unable to connect to #{url}: #{e}"
      end

      !user_api_key.nil?
    end
  end


    def octopus_deploy_user(*url_and_api_key, user_name)
      serverUrl, apiKey = get_octopus_creds(url_and_api_key)
      OctopusDeployUser.new(serverUrl, apiKey, user_name)
    end

    def octopus_user(*url_and_api_key, user_name)
      serverUrl, apiKey = get_octopus_creds(url_and_api_key)
      octopus_deploy_user(serverUrl, apiKey, user_name)
    end

    private

    def get_user_via_api(serverUrl, apiKey, user_name)
      user = nil

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

include Serverspec::Type