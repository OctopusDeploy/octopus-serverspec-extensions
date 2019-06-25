require 'serverspec'
require 'rspec/teamcity'
require 'webmock/rspec'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "octopus_serverspec_extensions"

set :backend, :cmd
set :os, :family => 'windows'

RSpec.configure do |c|
  if ENV['TEAMCITY_PROJECT_NAME'] && !ENV['TEAMCITY_PROJECT_NAME'].empty?
    c.add_formatter Spec::Runner::Formatter::TeamcityFormatter
  end
  c.before { allow($stdout).to receive(:puts) } # suppress 'puts' in the tests, for prettiness
end

def get_api_example(api_path)
  file_path = "./spec/octopus/serverspec/json#{api_path}.json"
  raise "API Example #{api_path} not found in file #{file_path}" unless File.exists?(file_path)
  File.read(file_path)
end

def mock_api_example(api_path)
  file_path = "./spec/octopus/serverspec/json#{api_path}.json"
  raise "API Example #{api_path} not found in file #{file_path}" unless File.exists?(file_path)
  stub_request(:get, "https://octopus.example.com/#{api_path}").
      to_return(status: 200, body: File.read(file_path), headers: {})
end