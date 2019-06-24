require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployTeam < Base
    @serverUrl = nil
    @apiKey = nil
    @serverSupportsSpaces = false
    @team = nil

    def initialize(*url_and_api_key, team_name, space_name)
      serverUrl,apiKey = get_octopus_creds(url_and_api_key)

      @name = "Octopus Deploy User Account #{serverUrl}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if team_name.nil?
        raise "'team_name' was not provided"
      end

      @team = get_team_via_api(serverUrl, apiKey, team_name, space_name)
    end

    def octopus_deploy_team(*url_and_api_key, team_name, space_name)
      serverUrl,apiKey = get_octopus_creds(url_and_api_key)
      OctopusDeployTeam.new(serverUrl, apiKey, team_name, space_name)
    end

    private

    def get_team_via_api(serverUrl, apiKey, team_name, spaceId)
      team = nil

      url = "#{serverUrl}/api#{@spaceFragment}/teams/all?api-key=#{apiKey}"

      begin
        resp = Net::HTTP.get_response(URI.parse(url))
        body = JSON.parse(resp.body)
        teams = body unless body.nil?
        team = teams.select {|i| i['Username'] == user_name }.first unless users.nil?
      rescue => e
        raise "get_smtp_config_via_api: Unable to connect to #{url}: #{e}"
      end

      team
    end

  end
end

include Serverspec::Type