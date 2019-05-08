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

    def initialize(serverUrl, apiKey, projectgroup_name, spaceID = 'Spaces-1')
      @name = "Octopus Deploy Project Group #{projectgroup_name}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey
      @spaceId = spaceID

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

    def in_space?(space_name)
      return false if @projectgroup.nil?
      return false if @serverSupportsSpaces
      url = "#{@serverUrl}/api/#{@spaceFragment}spaces/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      spaces = JSON.parse(resp.body)
      space_id = spaces.select {|e| e["Name"] == space_name}.first["Id"]
      @projectgroup["SpaceId"] == space_id
    end

    def in_environment?(environment_name)
      return false if @projectgroup.nil?
      url = "#{@serverUrl}/api/#{@spaceFragment}environments/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      environments = JSON.parse(resp.body)
      environment_id = environments.select {|e| e["Name"] == environment_name}.first["Id"]
      !@projectgroup["EnvironmentIds"].select {|e| e == environment_id}.empty?
    end
  end

  def octopus_deploy_projectgroup(serverUrl, apiKey, projectgroup_name, spaceID)
    OctopusDeployProjectGroup.new(serverUrl, apiKey, projectgroup_name, spaceID)
  end

  private

  def get_projectgroup_via_api(serverUrl, apiKey, projectgroup_name)
    projectgroup = nil
    url = "#{serverUrl}/api/#{@spaceFragment}projectgroups/all?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      projectgroup = body.select {|i| i['Name'] == projectgroup_name } unless body.nil?
    rescue => e
      raise "get_projectgroup_via_api: Unable to connect to #{url}: #{e}"
    end

    projectgroup[0] # it's an array, and we need the first object from it
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

end

include Serverspec::Type