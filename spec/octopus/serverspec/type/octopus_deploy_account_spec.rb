require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployAccount do

  let(:runner) { double ("runner")}

  it "throws if `serverUrl` not supplied" do
    expect { OctopusDeployAccount.new(nil, "someapikey", "my new account") }.
        to raise_error(/serverUrl/)
  end

  it "throws if `apiKey` not supplied" do
    expect { OctopusDeployAccount.new("https://someserver.com", nil, "my new account") }.
        to raise_error(/apiKey/)
  end

  it "throws if `accountName` not supplied" do
    expect { OctopusDeployAccount.new("https://someserver.com", "API-kllkjhasdkljhasdfkjsafd", nil) }.
        to raise_error(/account_name/)
  end

  example_account_found_response = File.open('spec/octopus/serverspec/json/accountsall.json')

  it "handles account found" do
    stub_request(:get, "https://octopus.example.com/api/accounts/all?api-key=API-1234567890").
        to_return(status: 200, body: example_account_found_response, headers: {})
    wp = OctopusDeployAccount.new("https://octopus.example.com", "API-1234567890", "exampleorganisation-azure")
    expect(wp.exists?).to be true
  end

  example_account_notfound_response = File.open('spec/octopus/serverspec/json/accountsall.json')

  it "handles account not found" do
    stub_request(:get, "https://octopus2.example.com/api/accounts/all?api-key=API-0987654321").
        to_return(status: 200, body: example_account_notfound_response, headers: {})
    wp = OctopusDeployAccount.new("https://octopus2.example.com", "API-0987654321", "Nonexistent Account")
    expect(wp.exists?).to be false
  end

  it "doesn't crash badly if handed a bad URL" do
    stub_request(:get, "https://nonexistentdomain.com/api/accounts/all?api-key=API-1234567890").to_raise(SocketError)

    expect { OctopusDeployAccount.new("https://nonexistentdomain.com", "API-1234567890", "exampleorganisation-azure") }.to raise_error(StandardError)
  end

end