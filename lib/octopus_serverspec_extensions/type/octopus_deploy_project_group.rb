require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployProjectGroup < Base
    @projectgroup = nil
    @serverUrl = nil
    @apiKey = nil
    @serverSupportsSpaces = nil
    @spaceId = nil
    @spaceFragment = ""

    def initialize(*url_and_api_key, projectgroup_name, space_name)
      serverUrl, apiKey = get_octopus_creds(url_and_api_key)

      @name = "Octopus Deploy Project Group #{projectgroup_name}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey


      if serverUrl.nil?
        raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if apiKey.nil?
        raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if projectgroup_name.nil?
        raise "'projectgroup_name' was not provided. Unable to connect to Octopus server to validate configuration."
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

      @projectgroup = get_projectgroup_via_api(serverUrl, apiKey, projectgroup_name)
    end

    def exists?
      (!@projectgroup.nil?) && (@projectgroup != [])
    end

    def has_description?(projectgroup_description)
      return false if @projectgroup.nil?
      @projectgroup["Description"] == projectgroup_description
    end
  end

  def octopus_deploy_projectgroup(*url_and_api_key, projectgroup_name, space_name)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)

    OctopusDeployProjectGroup.new(serverUrl, apiKey, projectgroup_name, space_name)
  end

  def octopus_deploy_project_group(*url_and_api_key, projectgroup_name, space_name)
    url, apikey = get_octopus_creds(url_and_api_key)
    octopus_deploy_projectgroup(url, apikey, projectgroup_name, space_name)
  end

  def octopus_project_group(*url_and_api_key, projectgroup_name, space_name)
    url, apikey = get_octopus_creds(url_and_api_key)
    octopus_deploy_projectgroup(url, apikey, projectgroup_name, space_name)
  end

  def octopus_projectgroup(*url_and_api_key, projectgroup_name, space_name)
    url, apikey = get_octopus_creds(url_and_api_key)
    octopus_deploy_projectgroup(url, apikey, projectgroup_name, space_name)
  end

  private

  def get_projectgroup_via_api(serverUrl, apiKey, projectgroup_name)
    pg = nil
    url = "#{serverUrl}/api/#{@spaceFragment}projectgroups/all?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      pg = body.select {|i| i['Name'] == projectgroup_name }.first unless body.nil?
    rescue => e
      raise "get_projectgroup_via_api: Unable to connect to #{url}: #{e}"
    end

    pg
  end

  def get_space_id?(space_name)
    url = "#{@serverUrl}/api/Spaces/all?api-key=#{@apiKey}"
    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      spaces = JSON.parse(resp.body)
      space_id = spaces.select {|e| e["Name"] == space_name}.first["Id"]
    rescue
      raise "get_space_id: unable to connect to #{url}: #{e}"
    end
    space_id
  end

end

include Serverspec::Type