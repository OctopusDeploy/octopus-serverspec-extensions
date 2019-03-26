require 'serverspec'
require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployWorkerPool < Base
    @worker_pool = nil
    @serverUrl = nil
    @apiKey = nil

    def initialize(serverUrl, apiKey, worker_pool_name)
      @name = "Octopus Deploy Worker Pool #{worker_pool_name}"
      @runner = Specinfra::Runner
      @serverUrl = serverUrl
      @apiKey = apiKey

      if (serverUrl.nil?)
        puts "'serverUrl' was not provided. Unable to connect to Octopus server to validate configuration."
        return
      end
      if (apiKey.nil?)
        puts "'apiKey' was not provided. Unable to connect to Octopus server to validate configuration."
        return
      end

      @worker_pool = get_worker_pool_via_api(serverUrl, apiKey, worker_pool_name)
    end

    def exists?
      !@worker_pool.nil?
    end
  end

  def octopus_deploy_worker_pool(serverUrl, apiKey, worker_pool_name)
    OctopusDeployWorkerPool.new(serverUrl, apiKey, worker_pool_name)
  end

  private

  def get_worker_pool_via_api(serverUrl, apiKey, worker_pool_name)
    worker_pool = nil
    url = "#{serverUrl}/api/workerpools/all?api-key=#{apiKey}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
      body = JSON.parse(resp.body)
      worker_pool = body.select {|i| i['Name'] == worker_pool_name } unless body.nil?
    rescue => e
      puts "Unable to connect to #{url}: #{e}"
    end

    worker_pool
  end
end

include Serverspec::Type
