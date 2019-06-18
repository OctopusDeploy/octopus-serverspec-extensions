

require 'rspec/teamcity'
require 'serverspec'

# puts $LOADED_FEATURES

set :backend, :cmd
set :os, :family => 'windows'

server_url = ENV['OCTOPUS_CLI_SERVER']
api_key = ENV['OCTOPUS_CLI_API_KEY']

RSpec.configure do |c|
  if (ENV['TEAMCITY_PROJECT_NAME']) then
    c.add_formatter Spec::Runner::Formatter::TeamcityFormatter
  end
end

describe octopus_deploy_projectgroup(server_url, api_key, 'CloudFormation Environment Build','Octopus') do
  it { should exist }
end

describe octopus_deploy_projectgroup(server_url, api_key, 'CloudFormation Environment Build','Octopus') do
  it { should exist }
  it { should have_description nil }
end

describe octopus_deploy_projectgroup(server_url, api_key, 'Step Templates',  'Default') do
  it { should have_description 'Octopus Step Template Testing' }
end

describe octopus_deploy_projectgroup(server_url, api_key, 'Step Templates', 'Default') do
  it { should have_description 'Octopus Step Template Testing' }
end

describe octopus_deploy_smtp_config(server_url, api_key) do
  it { should be_configured }
end
