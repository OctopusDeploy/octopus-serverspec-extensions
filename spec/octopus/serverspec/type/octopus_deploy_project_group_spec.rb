require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployProjectGroup do

  let(:runner) { double ("runner")}

  it "throws if `serverUrl` not supplied and no env vars present" do
    allow_any_instance_of(OctopusDeployProjectGroup).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return(nil)
    allow_any_instance_of(OctopusDeployProjectGroup).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return(nil)

    expect { OctopusDeployProjectGroup.new(nil, "someapikey", "my new projectgroup", 'Default') }.
        to raise_error(/credentials invalid/)
  end

  it "throws if `apiKey` not supplied and no env vars present" do
    allow_any_instance_of(OctopusDeployProjectGroup).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return(nil)
    allow_any_instance_of(OctopusDeployProjectGroup).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return(nil)

    expect { OctopusDeployProjectGroup.new("https://someserver.com", nil, "my new projectgroup", 'Default') }.
        to raise_error(/credentials invalid/)
  end

  it "throws if `ProjectGroupName` not supplied" do
    ex_does_not_support_spaces = get_api_example('/api/2018.7.9')
    ex_pg_found_response = get_api_example('/api/projectgroups/all')
    stub_request(:get, "https://someserver.com/api/").
        to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
    stub_request(:get, "https://someserver.com/api/projectgroups/all?api-key=API-kllkjhasdkljhasdfkjsafd").
        to_return(status: 200, body: ex_pg_found_response, headers: {})

    expect { OctopusDeployProjectGroup.new("https://someserver.com", "API-kllkjhasdkljhasdfkjsafd", nil, ).exists? }.
        to raise_error(/project_group_name/)
  end

  context "Server does not support spaces" do

    ex_does_not_support_spaces = get_api_example('/api/2018.7.9')
    ex_pg_found_response = get_api_example('/api/projectgroups/all')

    it "can use the env vars if you don't supply creds" do
      allow_any_instance_of(OctopusDeployProjectGroup).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return("API-1234567890")
      allow_any_instance_of(OctopusDeployProjectGroup).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return("https://octopus.example.local")

      stub_request(:get, "https://octopus.example.local/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus.example.local/api/projectgroups/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_pg_found_response, headers: {})

      pg = OctopusDeployProjectGroup.new("Octopus Projects")
    end

    it "handles project group found" do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/projectgroups/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_pg_found_response, headers: {})

      pg = OctopusDeployProjectGroup.new("https://octopus.example.com", "API-1234567890", "Octopus Projects")
      expect(pg.exists?).to be true
    end

    ex_pg_notfound_response = get_api_example('/api/projectgroups/all')

    it "handles project group not found" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/projectgroups/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_pg_notfound_response, headers: {})

      pg = OctopusDeployProjectGroup.new("https://octopus2.example.com", "API-0987654321", "Nonexistent projectgroup")
      expect(pg.exists?).to be false
    end

    it "doesn't crash badly if handed a bad URL" do  # not a very meaningful test these days
      stub_request(:get, "https://nonexistentdomain.com/api/").to_raise(SocketError)
      stub_request(:get, "https://nonexistentdomain.com/api/projectgroups/all?api-key=API-1234567890").to_raise(SocketError)

      expect { OctopusDeployProjectGroup.new("https://nonexistentdomain.com", "API-1234567890", "Octopus Projects") }.to raise_error(StandardError)
    end
  end

  context "Server supports spaces" do

    ex_supports_spaces = get_api_example('/api/2019.4.5')
    ex_pg_found = get_api_example('/api/Spaces-2/projectgroups/all')
    ex_spaces_all = get_api_example('/api/spaces/all')

    it "handles project group found, space name supplied" do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces-2/projectgroups/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_pg_found, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_spaces_all, headers: {})

      pg = OctopusDeployProjectGroup.new("https://octopus.example.com", "API-1234567890", "Octopus Projects").in_space('Second')
      expect(pg.exists?).to be true
    end

    ex_pg_notfound_response = get_api_example('/api/Spaces-1/projectgroups/all')

    it "handles projectgroup not found, space name not supplied (default space)" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_spaces_all, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces-1/projectgroups/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_pg_notfound_response, headers: {})

      pg = OctopusDeployProjectGroup.new("https://octopus2.example.com", "API-0987654321", "Nonexistent projectgroup").in_space('Default')
      expect(pg.exists?).to be false
    end

    it "Correctly checks the 'description' field" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces-2/projectgroups/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_pg_notfound_response, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_spaces_all, headers: {})


<<<<<<< HEAD
      pg = OctopusDeployProjectGroup.new("https://octopus2.example.com", "API-0987654321", "Octopus Projects").in_space('Octopus')
=======
      pg = OctopusDeployProjectGroup.new("https://octopus2.example.com", "API-0987654321", "Octopus Projects", "Second")
>>>>>>> master
      expect(pg.has_description?("This is a group of Octopus-related Projects")).to be true
    end

  end

end 