require 'serverspec/type/base'
require 'net/http'
require 'json'

module Serverspec::Type
  class OctopusDeployUser < Base

    private

    def get_user_via_api(serverUrl, apiKey, user_name)
      pg = nil
      url = "#{serverUrl}/smtpconfiguration?api-key=#{apiKey}"

      begin
        resp = Net::HTTP.get_response(URI.parse(url))
        body = JSON.parse(resp.body)
        smtp = body unless body.nil?
      rescue => e
        raise "get_smtp_config_via_api: Unable to connect to #{url}: #{e}"
      end

      smtp
    end

  end
end

include Serverspec::Type