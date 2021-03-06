require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployEnvironment < Base
    @environment = nil
    @environment_name = nil
    @serverUrl = nil
    @apiKey = nil
    @spaceId = nil
    @spaceFragment = ""

    def initialize(*url_and_api_key, environment_name)
      serverUrl, apiKey = get_octopus_creds(url_and_api_key)

      @environment_name = environment_name
      @name = "Octopus Deploy Environment #{environment_name}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if environment_name.nil?
        raise "'environment_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end

      @serverSupportsSpaces = check_supports_spaces(serverUrl)
    end

    def exists?
      load_resource_if_nil
      (!@environment.nil?) && (@environment != [])
    end

    def use_guided_failure?
      load_resource_if_nil
      false if @environment.nil?
      @environment['UseGuidedFailure'] == true
    end

    def allow_dynamic_infrastructure?
      load_resource_if_nil
      false if @environment.nil?
      @environment['AllowDynamicInfrastructure'] == true
    end

    def in_space(space_name)
      # allows us to tag .in_space() onto the end of the resource. as in
      # describe octopus_account("account name").in_space("MyNewSpace") do
      @spaceId = get_space_id(space_name)
      if @environment_name.nil?
        raise "'environment_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if(@spaceId.nil?)
        raise "unable to resolve space '#{@spaceId}'"
      end
      self
    end

    private

    def load_resource_if_nil
      if @environment.nil?
        @environment = get_environment_via_api(@serverUrl, @apiKey, @environment_name)
      end
    end

    def get_space_id(space_name)
      return false if @serverSupportsSpaces.nil?
      url = "#{@serverUrl}/api/Spaces/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      spaces = JSON.parse(resp.body)
      space_id = spaces.select {|e| e["Name"] == space_name}.first["Id"]
      space_id
    end
  end

  # module-level constructors/entrypoints

  def octopus_deploy_environment(*url_and_api_key, environment_name)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)

    OctopusDeployEnvironment.new(serverUrl, apiKey, environment_name)
  end

  def octopus_environment(*url_and_api_key, environment_name)
    serverUrl, apiKey = get_octopus_creds(url_and_api_key)

    OctopusDeployEnvironment.new(serverUrl, apiKey, environment_name)
  end

  private

  def get_environment_via_api(serverUrl, apiKey, environment_name)
    environment = nil

    unless @spaceId.nil?
      # set the spaceId correctly
      @spaceFragment = "#{@spaceId}/"
    end

    url = "#{serverUrl}/api/#{@spaceFragment}environments?name=#{environment_name}&api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      environment = body['Items'].first unless body.nil?
    rescue => e
      raise "Unable to connect to #{url}: #{e}"
    end

    environment
  end
end

include Serverspec::Type
