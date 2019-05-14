require 'serverspec'
require 'rspec/teamcity'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "octopus_serverspec_extensions"

set :backend, :cmd
set :os, :family => 'windows'

RSpec.configure do |c|
  if (ENV['TEAMCITY_PROJECT_NAME'] && !ENV['TEAMCITY_PROJECT_NAME'].empty?) then
    c.add_formatter Spec::Runner::Formatter::TeamcityFormatter
  end
end

def get_api_example(api_path)
  file_path = "./spec/octopus/serverspec/json#{api_path}.json"
  raise "API Example #{api_path} not found in file #{file_path}" if !File.exists?(file_path)
  File.read(file_path)
end