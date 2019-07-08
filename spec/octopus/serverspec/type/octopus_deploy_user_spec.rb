require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployUser do

  let(:runner) { double ("runner")}

  example_user_response = get_api_example('/api/users/all')

  before(:each) do
    allow_any_instance_of(OctopusDeployUser).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return("API-1234567890")
    allow_any_instance_of(OctopusDeployUser).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return("https://octopus.example.com")
    stub_request(:get, "https://octopus.example.com/api/users/all?api-key=API-1234567890").
        to_return(status: 200, body: example_user_response, headers: {})
  end

  it "finds a user that exists (no creds provided)" do
    expect(OctopusDeployUser.new('jasbro').exists?).to be true
    expect(OctopusDeployUser.new('IanNotReal').exists?).to be false
  end

  it "finds a user that exists (creds provided)" do
    expect(OctopusDeployUser.new('https://octopus.example.com', 'API-1234567890', 'jasbro').exists?).to be true
    expect(OctopusDeployUser.new('https://octopus.example.com', 'API-1234567890', 'IanNotReal').exists?).to be false
  end

  it "Can detect a service account" do
    expect(OctopusDeployUser.new('github').service_account?).to be true
    expect(OctopusDeployUser.new('jasbro').service_account?).to be false
  end

  it "Can detect an inactive account" do
    expect(OctopusDeployUser.new('inactive').active?).to be false
    expect(OctopusDeployUser.new('github').active?).to be true
  end

  it "can detect an email address" do
    expect(OctopusDeployUser.new('jasbro').has_email?('jasbro@example.com')).to be true
    expect(OctopusDeployUser.new('github').has_email?('github@example.com')).to be false
  end

  it "can detect a display name" do
    expect(OctopusDeployUser.new('github').has_display_name?('GitHub Service Account')).to be true
    expect(OctopusDeployUser.new('jasbro').has_display_name?('GitHub Service Account')).to be false
  end

  context "testing API Key detection" do
    example_api_key_response = get_api_example('/api/users/Users-61/apikeys')
    before(:each) do
      allow_any_instance_of(OctopusDeployUser).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return("API-1234567890")
      allow_any_instance_of(OctopusDeployUser).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return("https://octopus.example.com")
      stub_request(:get, "https://octopus.example.com/api/users/Users-61/apikeys?api-key=API-1234567890&take=200").
          to_return(status: 200, body: example_api_key_response, headers: {})
      stub_request(:get, "https://octopus.example.com/api/users/all?api-key=API-1234567890").
          to_return(status: 200, body: example_user_response, headers: {})
    end

    it "Can detect an API key" do
      expect(OctopusDeployUser.new('github').has_api_key?('Always Be Batman')).to be true
    end

    it "Can detect a nonexistent API key" do
      expect(OctopusDeployUser.new('github').has_api_key?('Never Be Batman')).to be false
    end
  end
end
