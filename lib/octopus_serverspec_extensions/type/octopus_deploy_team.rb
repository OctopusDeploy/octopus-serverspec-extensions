require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployTeam < Base
    @team_name = nil
    @serverUrl = nil
    @apiKey = nil
    @serverSupportsSpaces = false
    @team = nil
    @spaceId = nil

    def initialize(*url_and_api_key, team_name)
      serverUrl,apiKey = get_octopus_creds(url_and_api_key)

      @team_name = team_name

      @name = "Octopus Deploy User Account #{serverUrl}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if team_name.nil?
        raise "'team_name' was not provided"
      end
    end

    def exists?
      load_resource_if_nil
      @team != nil?
    end

    def in_space(space_name)
      # allows us to tag .in_space() onto the end of the resource. as in
      # describe octopus_account("account name").in_space("MyNewSpace") do
      @spaceId = get_space_id?(space_name)
      if @team_name.nil?
        raise "'team_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      self
    end

    def load_resource_if_nil
      if @team.nil?
        @team = get_team_via_api(@serverUrl, @apiKey, @team_name)
      end
    end
  end

  def octopus_deploy_team(*url_and_api_key, team_name)
    serverUrl,apiKey = get_octopus_creds(url_and_api_key)
    OctopusDeployTeam.new(serverUrl, apiKey, team_name)
  end

  def octopus_team(*url_and_api_key, team_name)
    serverUrl,apiKey = get_octopus_creds(url_and_api_key)
    OctopusDeployTeam.new(serverUrl, apiKey, team_name)
  end

  private

  def get_team_via_api(serverUrl, apiKey, team_name)
    team = nil

    url = "#{serverUrl}/api#{@spaceFragment}/teams/all?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      teams = body unless body.nil?
      team = teams.select {|i| i['Name'] == team_name }.first unless teams.nil?
    rescue => e
      raise "get_team_via_api: Unable to connect to #{url}: #{e}"
    end

    team
  end

end

include Serverspec::Type