require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployWorker < Base
    @worker = nil
    @serverUrl = nil
    @apiKey = nil
    @serverSupportsSpaces = nil
    @spaceId = nil
    @spaceFragment = ""

    def initialize(serverUrl, apiKey, instance, spaceId = 'Spaces-1')
      @name = "Octopus Deploy Worker #{instance}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey
      @spaceId = spaceId

      if (serverUrl.nil?)
        raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if (apiKey.nil?)
        raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
      end

      if (exists?)
        thumbprint = `"c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe" show-thumbprint --console --nologo --instance #{instance}`
        thumbprint = thumbprint.gsub('==== ShowThumbprintCommand starting ====', '').strip
        thumbprint = thumbprint.gsub('The thumbprint of this Tentacle is: ', '').strip
        thumbprint = thumbprint.gsub('==== ShowThumbprintCommand completed ====', '').strip
        thumbprint = thumbprint.gsub('==== ShowThumbprintCommand ====', '').strip

        @serverSupportsSpaces = check_supports_spaces(serverUrl)

        if (@serverSupportsSpaces)
          @spaceFragment = "#{@spaceId}/"
        end

        @worker = get_worker_via_api(serverUrl, apiKey, thumbprint)
      else
        raise "tentacle.exe does not exist"
      end
    end

    def registered_with_the_server?
      !@worker.nil?
    end

    def online?
      return nil if @worker.nil?
      @worker = poll_until_worker_has_completed_healthcheck(@serverUrl, @apiKey, @worker["Thumbprint"])
      status = @worker['Status']
      if ("#{status}" == "")
        status = @worker['HealthStatus'] if "#{status}" == ""
        puts "Expected status 'Healthy|HasWarnings' for Worker #{@name}, but got '#{status}'" if (status != "Healthy" && status != "HasWarnings")
        status == "Healthy" || status == "HasWarnings"
      else
        puts "Expected status 'Online|CalamariNeedsUpgrade|NeedsUpgrade' for Worker #{@name}, but got '#{status}'" if (status != "Online" && status != "CalamariNeedsUpgrade" && status != "NeedsUpgrade")
        status == "Online" || status == "CalamariNeedsUpgrade" || status == "NeedsUpgrade"
      end
    end

    def in_space?(space_name)
      return false if @worker.nil?
      return false if @serverSupportsSpaces
      url = "#{@serverUrl}/api/spaces/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      spaces = JSON.parse(resp.body)
      space_id = spaces.select {|e| e["Name"] == space_name}.first["Id"]
      @worker["SpaceId"] == space_id
    end

    def has_policy?(policy_name)
      return false if @worker.nil?
      url = "#{@serverUrl}/api/#{@spaceFragment}machinepolicies/all?api-key=#{@apiKey}"
      resp = Net::HTTP.get_response(URI.parse(url))
      policies = JSON.parse(resp.body)
      policy_id = policies.select {|e| e["Name"] == policy_name}.first["Id"]
      @worker["MachinePolicyId"] == policy_id
    end

    def has_display_name?(name)
      return false if @worker.nil?
      @worker["Name"] == name
    end

    def has_endpoint?(uri)
      return false if @worker.nil?
      return false if @worker["Uri"].nil? # polling tentacles have null endpoint. catch that.
      puts "Expected uri '#{uri}' for Worker #{@name}, but got '#{@worker["Uri"]}'" unless (@worker["Uri"].casecmp(uri) == 0)
      @worker["Uri"].casecmp(uri) == 0
    end

    def listening_tentacle?
      return false if @worker.nil?
      puts "Expected CommunicationStyle 'TentaclePassive' for Tentacle #{@name}, but got '#{@worker["Endpoint"]["CommunicationStyle"]}'" if (@worker["Endpoint"]["CommunicationStyle"] != "TentaclePassive")
      @worker["Endpoint"]["CommunicationStyle"] == "TentaclePassive"
    end

    def polling_tentacle?
      return false if @worker.nil?
      puts "Expected CommunicationStyle 'TentacleActive' for Tentacle #{@name}, but got '#{@worker["Endpoint"]["CommunicationStyle"]}'" if (@worker["Endpoint"]["CommunicationStyle"] != "TentacleActive")
      @worker["Endpoint"]["CommunicationStyle"] == "TentacleActive"
    end

    def exists?
      ::File.exists?("c:\\program files\\Octopus Deploy\\Tentacle\\Tentacle.exe")
    end
  end

  def octopus_deploy_worker(serverUrl, apiKey, instance)
    OctopusDeployWorker.new(serverUrl, apiKey, instance)
  end

  private

  def check_supports_spaces(serverUrl)
    begin
      resp = Net::HTTP.get_response(URI.parse("#{serverUrl}/api/"))
      body = JSON.parse(resp.body)
      version = body['Version']
      return Gem::Version.new(version) > Gem::Version.new('2019.0.0')
    rescue => e
      puts "Unable to connect to #{serverUrl}: #{e}"
    end

    return false
  end

  def poll_until_worker_has_completed_healthcheck(serverUrl, apiKey, thumbprint)
    worker = nil
    url = "#{serverUrl}/api/#{@spaceFragment}workers/all?api-key=#{apiKey}"

    now = Time.now
    counter = 1
    loop do
      worker = get_worker_via_api(serverUrl, apiKey, thumbprint)

      break if worker.nil?
      break if counter > 10
      break if !worker_healthcheck_outstanding(worker)
      puts "Machine health check for #{worker["Name"]} has not yet completed. Waiting 5 seconds to try again."
      counter += 1
      sleep 5
    end

    worker
  end

  def worker_healthcheck_outstanding(worker)
    worker["StatusSummary"] == "This worker was recently added. Please perform a health check."
  end

  def get_worker_via_api(serverUrl, apiKey, thumbprint)
    worker = nil
    url = "#{serverUrl}/api/#{@spaceFragment}workers/all?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      worker = body.select {|e| e["Thumbprint"] == thumbprint}.first unless body.nil?
    rescue => e
      puts "Unable to connect to #{url}: #{e}"
    end

    worker
  end
end

include Serverspec::Type
