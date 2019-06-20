require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployUser do

  let(:runner) { double ("runner")}

  example_user_response = get_api_example('/api/users/all')

  it "finds a user that exists (no creds provided)" do

    allow_any_instance_of(OctopusDeployUser).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return("API-1234567890")
    allow_any_instance_of(OctopusDeployUser).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return("https://octopus.example.com")
    stub_request(:get, "https://octopus.example.com/api/users/all?api-key=API-1234567890").
        to_return(status: 200, body: example_user_response, headers: {})

    expect(OctopusDeployUser.new('jasbro').exists?).to be true
    expect(OctopusDeployUser.new('IanNotReal').exists?).to be false
  end

  it "finds a user that exists (creds provided)" do
    stub_request(:get, "https://octopus.example.com/api/users/all?api-key=API-1234567890").
        to_return(status: 200, body: example_user_response, headers: {})

    expect(OctopusDeployUser.new('https://octopus.example.com', 'API-1234567890', 'jasbro').exists?).to be true
    expect(OctopusDeployUser.new('https://octopus.example.com', 'API-1234567890', 'IanNotReal').exists?).to be false
  end


end
