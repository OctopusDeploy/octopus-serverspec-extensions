require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployProjectGroup do

  let(:runner) { double ("runner")}

  it "throws if `serverUrl` not supplied" do
    expect { OctopusDeployProjectGroup.new(nil, "someapikey", "my new projectgroup") }.
        to raise_error(/serverUrl/)
  end

  it "throws if `apiKey` not supplied" do
    expect { OctopusDeployProjectGroup.new("https://someserver.com", nil, "my new projectgroup") }.
        to raise_error(/apiKey/)
  end

  it "throws if `ProjectGroupName` not supplied" do
    expect { OctopusDeployProjectGroup.new("https://someserver.com", "API-kllkjhasdkljhasdfkjsafd", nil) }.
        to raise_error(/projectgroup_name/)
  end

  context "Server does not support spaces" do

    ex_does_not_support_spaces = get_api_example('/api/2018.7.9')
    ex_pg_found_response = get_api_example('/api/projectgroups/all')

    it "handles projectgroup found, in a specific space" do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/projectgroups/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_pg_found_response, headers: {})

      pg = OctopusDeployProjectGroup.new("https://octopus.example.com", "API-1234567890", "Octopus Projects")
      expect(pg.exists?).to be true
    end

    ex_pg_notfound_response = get_api_example('/api/projectgroups/all')

    it "handles projectgroup not found" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/projectgroups/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_pg_notfound_response, headers: {})

      pg = OctopusDeployProjectGroup.new("https://octopus2.example.com", "API-0987654321", "Nonexistent projectgroup")
      expect(pg.exists?).to be false
    end

    it "doesn't crash badly if handed a bad URL" do
      stub_request(:get, "https://nonexistentdomain.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
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


      pg = OctopusDeployProjectGroup.new("https://octopus.example.com", "API-1234567890", "Octopus Projects", "Octopus")
      expect(pg.exists?).to be true

    end

    ex_pg_found_space_one = get_api_example('/api/Spaces-1/projectgroups/all')

    it "resolves the default space if we don't supply it" do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces-1/projectgroups/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_pg_found_space_one, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_spaces_all, headers: {})


      pg = OctopusDeployProjectGroup.new("https://octopus.example.com", "API-1234567890", "DSC")
      expect(pg.exists?).to be true
    end

    ex_pg_notfound_response = get_api_example('/api/Spaces-1/projectgroups/all')

    it "handles projectgroup not found, space name not supplied (default space)" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces-1/projectgroups/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_pg_notfound_response, headers: {})

      pg = OctopusDeployProjectGroup.new("https://octopus2.example.com", "API-0987654321", "Nonexistent projectgroup")
      expect(pg.exists?).to be false
    end

    it "doesn't crash badly if handed a bad URL" do
      stub_request(:get, "https://nonexistentdomain.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://nonexistentdomain.com/api/Spaces-1/projectgroups/all?api-key=API-1234567890").to_raise(SocketError)

      expect { OctopusDeployProjectGroup.new("https://nonexistentdomain.com", "API-1234567890", "Octopus Projects") }.to raise_error(StandardError)
    end

    it "Correctly checks the 'description' field" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces-2/projectgroups/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_pg_notfound_response, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_spaces_all, headers: {})


      pg = OctopusDeployProjectGroup.new("https://octopus2.example.com", "API-0987654321", "Octopus Projects", "Octopus")
      expect(pg.has_description?("This is a group of Octopus-related Projects")).to be true
    end

  end

end 