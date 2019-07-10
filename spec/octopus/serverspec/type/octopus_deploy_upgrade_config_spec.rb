require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployUpgradeConfig do

  let(:runner) { double ("runner")}

  example_config_response = get_api_example('/api/upgradeconfiguration')
  example_config_response2 = get_api_example('/api/upgradeconfiguration2')

  before(:each) do
    stub_request(:get, "https://octopus.example.com/api/upgradeconfiguration?api-key=API-1234567890").
        to_return(status: 200, body: example_config_response, headers: {})
  end

  it 'should handle being give no creds' do
    allow_any_instance_of(OctopusDeployUpgradeConfig).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return("API-1234567890")
    allow_any_instance_of(OctopusDeployUpgradeConfig).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return("https://octopus.example.com")

    my_upgrade_config = OctopusDeployUpgradeConfig.new()
    expect( my_upgrade_config.always_show_notifications? ).to be true
  end

  it 'should be able to detect NotificationMode' do
    my_upgrade_config = OctopusDeployUpgradeConfig.new("https://octopus.example.com", "API-1234567890")
    expect( my_upgrade_config.always_show_notifications? ).to be true
    expect( my_upgrade_config.never_show_notifications? ).to be false
    expect( my_upgrade_config.show_major_minor_notifications?).to be false
  end

  it 'should be able to detect NotificationMode test 2' do
    stub_request(:get, "https://octopus.example.com/api/upgradeconfiguration?api-key=API-1234567890").
        to_return(status: 200, body: example_config_response2, headers: {})

    my_upgrade_config = OctopusDeployUpgradeConfig.new("https://octopus.example.com", "API-1234567890")
    expect( my_upgrade_config.always_show_notifications? ).to be false
    expect( my_upgrade_config.never_show_notifications? ).to be true
    expect( my_upgrade_config.show_major_minor_notifications?).to be false
  end

  it 'should be able to detect AllowChecking' do
    my_upgrade_config = OctopusDeployUpgradeConfig.new("https://octopus.example.com", "API-1234567890")
    expect( my_upgrade_config.allow_checking?).to be true
  end

  it 'should be able to detect IncludeStatistics' do
    my_upgrade_config = OctopusDeployUpgradeConfig.new("https://octopus.example.com", "API-1234567890")
    expect( my_upgrade_config.include_statistics?).to be true
  end
end

