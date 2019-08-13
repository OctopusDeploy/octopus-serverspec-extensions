require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployWorkerPool < Base
    @worker_pool = nil
    @worker_pool_name = nil
    @serverUrl = nil
    @apiKey = nil

    def initialize(*url_and_api_key, worker_pool_name)
      serverUrl = get_octopus_url(url_and_api_key[0])
      apiKey = get_octopus_api_key(url_and_api_key[1])

      @worker_pool_name = worker_pool_name

      @name = "Octopus Deploy Worker Pool #{worker_pool_name}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if (serverUrl.nil?)
        raise "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if (apiKey.nil?)
        raise "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      if (worker_pool_name.nil?)
        raise "'worker_pool_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end

      @worker_pool = get_worker_pool_via_api(serverUrl, apiKey, worker_pool_name)
    end

    def in_space(space_name)
      # allows us to tag .in_space() onto the end of the resource. as in
      # describe octopus_worker_pool("account name").in_space("MyNewSpace") do
      @spaceId = get_space_id?(space_name)
      if @worker_pool_name.nil?
        raise "'worker_pool_name' was not provided. Unable to connect to Octopus server to validate configuration."
      end
      self
    end

    def exists?
      (!@worker_pool.nil?) && (@worker_pool != [])
    end
  end

  def octopus_deploy_worker_pool(*url_and_api_key, worker_pool_name)
    serverUrl, apiKey = get_octopus_url(url_and_api_key)

    OctopusDeployWorkerPool.new(serverUrl, apiKey, worker_pool_name)
  end

  def octopus_worker_pool(*url_and_api_key, worker_pool_name)
    serverUrl, apiKey = get_octopus_url(url_and_api_key)

    OctopusDeployWorkerPool.new(serverUrl, apiKey, worker_pool_name)
  end

  private

  def get_worker_pool_via_api(serverUrl, apiKey, worker_pool_name)
    worker_pool = nil

    if @serverSupportsSpaces
      # set the spaceId correctly
      @spaceFragment = "#{@spaceId}/"
    end

    url = "#{serverUrl}/api/#{@spaceFragment}workerpools/all?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      worker_pool = body.select {|i| i['Name'] == worker_pool_name } unless body.nil?
    rescue => e
      raise "Unable to connect to #{url}: #{e}"
    end

    worker_pool
  end
end

include Serverspec::Type
