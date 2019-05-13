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

  ex_does_not_support_spaces = File.read('spec/octopus/serverspec/json/apidoesnotsupportspaces.json')
  ex_acc_found_response = File.read('spec/octopus/serverspec/json/accountsall.json')

  it "throws correctly if we ask for a non-supported account type" do
    stub_request(:get, "https://octopus.example.com/api/").
        to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
    stub_request(:get, "https://octopus.example.com/api/accounts/all?api-key=API-1234567890").
        to_return(status: 200, body: ex_acc_found_response, headers: {})

    wp = OctopusDeployAccount.new("https://octopus.example.com", "API-1234567890", "exampleorganisation-azure")
    expect { wp.is_account_type?("NonExistentAccountType") }.to raise_error(/NonExistentAccountType/)
    expect(wp.is_account_type?( "AzureSubscription" )).to be true
  end

  context "Server does not support spaces" do

    ex_does_not_support_spaces = File.read('spec/octopus/serverspec/json/apidoesnotsupportspaces.json')
    ex_acc_found_response = File.read('spec/octopus/serverspec/json/accountsall.json')

    it "handles account found" do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/accounts/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_acc_found_response, headers: {})

      wp = OctopusDeployAccount.new("https://octopus.example.com", "API-1234567890", "exampleorganisation-azure")
      expect(wp.exists?).to be true
    end

    ex_acc_notfound_response = File.read('spec/octopus/serverspec/json/accountsall.json')

    it "handles account not found" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/accounts/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_acc_notfound_response, headers: {})

      wp = OctopusDeployAccount.new("https://octopus2.example.com", "API-0987654321", "Nonexistent Account")
      expect(wp.exists?).to be false
    end

    it "doesn't crash badly if handed a bad URL" do
      stub_request(:get, "https://nonexistentdomain.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://nonexistentdomain.com/api/accounts/all?api-key=API-1234567890").to_raise(SocketError)

      expect { OctopusDeployAccount.new("https://nonexistentdomain.com", "API-1234567890", "exampleorganisation-azure") }.to raise_error(StandardError)
    end

  end

  context "Server supports spaces" do

    ex_supports_spaces = File.read('spec/octopus/serverspec/json/apisupportsspaces.json')
    ex_account_found_response = File.read('spec/octopus/serverspec/json/accountsall.json')
    ex_spaces_all = File.read('spec/octopus/serverspec/json/spacesall.json')

    it "handles account found" do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces-1/accounts/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_account_found_response, headers: {})

      wp = OctopusDeployAccount.new("https://octopus.example.com", "API-1234567890", "exampleorganisation-azure")

      expect(wp.exists?).to be true
    end

    ex_account_notfound_response = File.read('spec/octopus/serverspec/json/accountsall.json')

    it "handles account not found" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces-1/accounts/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_account_notfound_response, headers: {})

      wp = OctopusDeployAccount.new("https://octopus2.example.com", "API-0987654321", "Nonexistent Account")
      expect(wp.exists?).to be false
    end

    it "doesn't crash badly if handed a bad URL" do
      stub_request(:get, "https://nonexistentdomain.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://nonexistentdomain.com/api/Spaces-1/accounts/all?api-key=API-1234567890").to_raise(SocketError)

      expect { OctopusDeployAccount.new("https://nonexistentdomain.com", "API-1234567890", "exampleorganisation-azure") }.to raise_error(StandardError)
    end

    it "Correctly checks the 'description' field" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_spaces_all, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces-2/accounts/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_account_notfound_response, headers: {})


      wp = OctopusDeployAccount.new("https://octopus2.example.com", "API-0987654321", "exampleorganisation2-azure", "Octopus")
      expect(wp.has_description?("This is an example Azure Subscription in Space 2")).to be true
    end

  end

end