require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployAccount do

  let(:runner) { double ("runner")}

  context "argument validation" do

    # assume we don't support spaces here
    ex_does_not_support_spaces = get_api_example('/api/2018.7.9')
    before(:each) do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      allow_any_instance_of(OctopusDeployAccount).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return(nil)
      allow_any_instance_of(OctopusDeployAccount).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return(nil)
    end

    it "throws if `serverUrl` not supplied" do
      expect { OctopusDeployAccount.new(nil, "someapikey", "my new account") }.
          to raise_error(/credentials invalid/)
    end

    it "throws if `apiKey` not supplied" do
      expect { OctopusDeployAccount.new("https://octopus.example.com", nil, "my new account") }.
          to raise_error(/credentials invalid/)
    end

    it "throws if `accountName` not supplied" do
      expect { OctopusDeployAccount.new("https://octopus.example.com", "API-kllkjhasdkljhasdfkjsafd", nil) }.
          to raise_error(/account_name/)
    end
  end


  context "Server does not support spaces" do

    ex_does_not_support_spaces = get_api_example('/api/2018.7.9')
    ex_acc_found_response = get_api_example('/api/accounts/all')

    before(:each) do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/accounts/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_acc_found_response, headers: {})
    end

    it "throws correctly if we ask for a non-supported account type" do

      wp = OctopusDeployAccount.new("https://octopus.example.com", "API-1234567890", "exampleorganisation-azure")
      expect { wp.account_type?("NonExistentAccountType") }.to raise_error(/NonExistentAccountType/)
      expect(wp.account_type?( "AzureSubscription" )).to be true
    end

    it "handles account found" do

      wp = OctopusDeployAccount.new("https://octopus.example.com", "API-1234567890", "exampleorganisation-azure")
      expect(wp.exists?).to be true
    end

    it "handles trailing slashes or not trailing slashes on URL" do

      expect { OctopusDeployAccount.new("https://octopus.example.com", "API-1234567890", "exampleorganisation-azure") }.not_to raise_exception
      expect { OctopusDeployAccount.new("https://octopus.example.com/", "API-1234567890", "exampleorganisation-azure") }.not_to raise_exception
    end

    ex_acc_notfound_response = get_api_example('/api/accounts/all')

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
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {}).to_raise(SocketError)
      stub_request(:get, "https://nonexistentdomain.com/api/accounts/all?api-key=API-1234567890").to_raise(SocketError)

      expect {
        ac = OctopusDeployAccount.new("https://nonexistentdomain.com", "API-1234567890", "exampleorganisation-azure")
        ac.exists? # must call an assertion against it, else it won't load from the API
      }.to raise_error(StandardError)
    end

  end

  context "Server supports spaces" do

    ex_supports_spaces = get_api_example('/api/2019.4.5')
    ex_account_found_response = get_api_example('/api/Spaces-1/accounts/all')
    ex_spaces_all = get_api_example('/api/spaces/all')

    before(:each) do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_spaces_all, headers: {})
    end

    it "handles account found" do
      stub_request(:get, "https://octopus.example.com/api/Spaces-1/accounts/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_account_found_response, headers: {})

      wp = OctopusDeployAccount.new("https://octopus.example.com", "API-1234567890", "exampleorganisation-azure").in_space("Default")

      expect(wp.exists?).to be true
    end

    ex_account_notfound_response = get_api_example('/api/Spaces-1/accounts/all')

    it "handles account not found" do
      stub_request(:get, "https://octopus.example.com/api/Spaces-1/accounts/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_account_notfound_response, headers: {})

      wp = OctopusDeployAccount.new("https://octopus.example.com", "API-1234567890", "Nonexistent Accoount").in_space('Default')
      expect(wp.exists?).to be false
    end

    it "doesn't crash badly if handed a bad URL" do
      stub_request(:get, "https://nonexistentdomain.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://nonexistentdomain.com/api/Spaces/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_spaces_all, headers: {})
      stub_request(:get, "https://nonexistentdomain.com/api/Spaces-1/accounts/all?api-key=API-1234567890").to_raise(SocketError)

      expect {
        ac = OctopusDeployAccount.new("https://nonexistentdomain.com", "API-1234567890", "exampleorganisation-azure").in_space('Default')
        ac.exists? # must call an assertion against it, else it won't load from the API
      }.to raise_error(StandardError)
    end

    ex_accounts_spaces_two = get_api_example('/api/Spaces-2/accounts/all')

    it "Correctly checks the 'description' field" do
      stub_request(:get, "https://octopus.example.com/api/Spaces-2/accounts/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_accounts_spaces_two, headers: {})


      wp = OctopusDeployAccount.new("https://octopus.example.com", "API-1234567890", "exampleorganisation-azure").in_space("Second")
      expect(wp.has_description?("This is an example Azure Subscription in Space 2")).to be true
      expect(wp.azure_account?).to be true
      expect(wp.account_type?(OctopusDeployAccount::AZURE))
    end

  end

end