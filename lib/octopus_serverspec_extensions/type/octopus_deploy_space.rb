require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeploySpace < Base
    @serverUrl = nil
    @apiKey = nil
    @spaceName = nil
    @space = nil

    def initialize(*url_and_api_key, space_name)
      serverUrl, apiKey = get_octopus_creds(url_and_api_key)

      @name = "Octopus Deploy Space #{space_name}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if space_name.nil?
        raise "'space_name' was not included. Cannot contact server to validate space"
      end

      @spaceName = space_name
    end

    def exists?
      load_resource_if_nil
      @space.nil? == false
    end

    def default?
      load_resource_if_nil
      false if @space.nil?
      @space['IsDefault'] == true
    end

    def has_running_task_queue?
      load_resource_if_nil
      false if @space.nil?
      @space['TaskQueueStopped'] == false
    end

    def has_description?(description)
      load_resource_if_nil
      false if @space.nil?
      @space['Description'] == description
    end

    def load_resource_if_nil
      if @space.nil?
        @space = get_space_via_api
      end
    end
  end

  def octopus_deploy_space(*url_and_api_key, space_name)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)
    OctopusDeploySpace.new(serverUrl, apiKey, space_name)
  end

  def octopus_space(*url_and_api_key, space_name)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)
    OctopusDeploySpace.new(serverUrl, apiKey, space_name)
  end

  private


  def get_space_via_api
    space = nil

    @serverSupportsSpaces = check_supports_spaces(@serverUrl)

    unless @serverSupportsSpaces
      raise "Server does not support Spaces"
    end

    url = "#{@serverUrl}/api/Spaces/all?api-key=#{@apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      space = body.select {|i| i['Name'] == @spaceName }.first unless body.nil?
    rescue => e
      raise "get_account_via_api: Unable to connect to #{url}: #{e}"
    end

    space
    end
end
