require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployProjectGroup < Base
    @project_group = nil
    @project_group_name = nil
    @serverUrl = nil
    @apiKey = nil
    @serverSupportsSpaces = nil
    @spaceId = nil
    @spaceFragment = ""

    def initialize(*url_and_api_key, project_group_name)
      serverUrl, apiKey = get_octopus_creds(url_and_api_key)

      @project_group_name = project_group_name

      @name = "Octopus Deploy Project Group #{project_group_name}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      @serverSupportsSpaces = check_supports_spaces(serverUrl)
    end

    def exists?
      load_resource_if_nil
      (!@project_group.nil?) && (@project_group != [])
    end

    def has_description?(project_group_description)
      load_resource_if_nil
      return false if @project_group.nil?
      @project_group["Description"] == project_group_description
    end

    def in_space(space_name)
      # allows us to tag .in_space() onto the end of the resource. as in
      # describe octopus_account("account name").in_space("MyNewSpace") do
      @spaceId = get_space_id(space_name)
      if @project_group_name.nil?
        raise "'project_group_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      self
    end

    private

    def get_space_id(space_name)
      return false if @serverSupportsSpaces.nil?
      url = "#{@serverUrl}/api/Spaces/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      spaces = JSON.parse(resp.body)
      space_id = spaces.select {|e| e["Name"] == space_name}.first["Id"]
      space_id
    end

    def load_resource_if_nil
      if @project_group.nil?
        @project_group = get_project_group_via_api(@serverUrl, @apiKey, @project_group_name)
      end
    end
  end

  # module-level constructors/entrypoints

  def octopus_deploy_projectgroup(*url_and_api_key, project_group_name) # deprecated - no underscore in name
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)
    OctopusDeployProjectGroup.new(serverUrl, apiKey, project_group_name)
  end

  def octopus_deploy_project_group(*url_and_api_key, project_group_name)
    url, apikey = get_octopus_creds(url_and_api_key)
    octopus_deploy_projectgroup(url, apikey, project_group_name)
  end

  def octopus_project_group(*url_and_api_key, project_group_name)
    url, apikey = get_octopus_creds(url_and_api_key)
    octopus_deploy_projectgroup(url, apikey, project_group_name)
  end

  def octopus_projectgroup(*url_and_api_key, project_group_name) # deprecated - no underscore in name
    url, apikey = get_octopus_creds(url_and_api_key)
    octopus_deploy_projectgroup(url, apikey, project_group_name)
  end

  private

  def get_project_group_via_api(serverUrl, apiKey, project_group_name)
    pg = nil

   raise "'project_group_name' not supplied" if(project_group_name.nil? || project_group_name == '')

    unless @spaceId.nil?
      @spaceFragment = "#{@spaceId}/"
    end

    url = "#{serverUrl}/api/#{@spaceFragment}projectgroups/all?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      pg = body.select {|i| i['Name'] == project_group_name }.first unless body.nil?
    rescue => e
      raise "get_project_group_via_api: Unable to connect to #{url}: #{e}"
    end

    pg
  end
end

include Serverspec::Type