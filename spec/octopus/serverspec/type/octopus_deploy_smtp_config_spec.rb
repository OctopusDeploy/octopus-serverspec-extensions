require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeploySmtpConfig do

  let(:runner) { double ("runner")}

  example_smtp_response = get_api_example('/api/smtpconfiguration')

  it "can use the environment vars instead of literal args" do
    allow_any_instance_of(OctopusDeploySmtpConfig).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return("API-1234567890")
    allow_any_instance_of(OctopusDeploySmtpConfig).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return("https://octopus.example.com")
    stub_request(:get, "https://octopus.example.com/api/smtpconfiguration?api-key=API-1234567890").
        to_return(status: 200, body: example_smtp_response, headers: {})

    my_smtp_config = OctopusDeploySmtpConfig.new(nil, nil)
    expect( my_smtp_config.on_host?('smtp.fictionaldomain.com')).to be true
    expect( my_smtp_config.on_host?('smtp.notfictionaldomain.com')).to be false
  end

  it "Can detect the DNS name in our dummy config" do
    stub_request(:get, "https://octopus.example.com/api/smtpconfiguration?api-key=API-1234567890").
        to_return(status: 200, body: example_smtp_response, headers: {})

    my_smtp_config = OctopusDeploySmtpConfig.new('https://octopus.example.com', 'API-1234567890')
    expect( my_smtp_config.on_host?('smtp.fictionaldomain.com')).to be true
    expect( my_smtp_config.on_host?('smtp.notfictionaldomain.com')).to be false
  end

  it "Should know we're on port 25" do
    stub_request(:get, "https://octopus.example.com/api/smtpconfiguration?api-key=API-1234567890").
        to_return(status: 200, body: example_smtp_response, headers: {})

    my_smtp_config = OctopusDeploySmtpConfig.new('https://octopus.example.com', 'API-1234567890')
    expect( my_smtp_config.on_port?(25)).to be true
    expect( my_smtp_config.on_port?(32)).to be false
  end

  it "Should detect SSL required" do
    stub_request(:get, "https://octopus.example.com/api/smtpconfiguration?api-key=API-1234567890").
        to_return(status: 200, body: example_smtp_response, headers: {})

    my_smtp_config = OctopusDeploySmtpConfig.new('https://octopus.example.com', 'API-1234567890')
    expect( my_smtp_config.uses_ssl?).to be true
  end

  it "should be able to detect isconfigured" do
    example_smtp_configured_response = get_api_example('/api/smtpconfiguration/isconfigured')
    stub_request(:get, "https://octopus.example.com/api/smtpconfiguration/isconfigured?api-key=API-1234567890").
        to_return(status: 200, body: example_smtp_configured_response, headers: {})
    stub_request(:get, "https://octopus.example.com/api/smtpconfiguration?api-key=API-1234567890").
        to_return(status: 200, body: example_smtp_response, headers: {})

    my_smtp_config = OctopusDeploySmtpConfig.new('https://octopus.example.com', 'API-1234567890')
    expect( my_smtp_config.configured?).to be true
  end

  it "can tell what username we have configured, and whether a password has been supplied" do
    stub_request(:get, "https://octopus.example.com/api/smtpconfiguration?api-key=API-1234567890").
        to_return(status: 200, body: example_smtp_response, headers: {})

    my_smtp_config = OctopusDeploySmtpConfig.new('https://octopus.example.com', 'API-1234567890')
    expect( my_smtp_config.using_credentials?('username')).to be true
  end

end
