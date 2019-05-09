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

  ex_does_not_support_spaces = File.read('spec/octopus/serverspec/json/apidoesnotsupportspaces.json')
  ex_acc_found_response = File.read('spec/octopus/serverspec/json/projectgroupsall.json')

  context "Server does not support spaces" do

    ex_does_not_support_spaces = File.read('spec/octopus/serverspec/json/apidoesnotsupportspaces.json')
    ex_acc_found_response = File.read('spec/octopus/serverspec/json/projectgroupsall.json')

    it "handles projectgroup found" do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/projectgroups/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_acc_found_response, headers: {})

      wp = OctopusDeployProjectGroup.new("https://octopus.example.com", "API-1234567890", "Octopus Projects")
      expect(wp.exists?).to be true
    end

    ex_acc_notfound_response = File.read('spec/octopus/serverspec/json/projectgroupsall.json')

    it "handles projectgroup not found" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/projectgroups/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_acc_notfound_response, headers: {})

      wp = OctopusDeployProjectGroup.new("https://octopus2.example.com", "API-0987654321", "Nonexistent projectgroup")
      expect(wp.exists?).to be false
    end

    it "doesn't crash badly if handed a bad URL" do
      stub_request(:get, "https://nonexistentdomain.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://nonexistentdomain.com/api/projectgroups/all?api-key=API-1234567890").to_raise(SocketError)

      expect { OctopusDeployProjectGroup.new("https://nonexistentdomain.com", "API-1234567890", "Octopus Projects") }.to raise_error(StandardError)
    end

  end

  context "Server supports spaces" do

    ex_supports_spaces = File.read('spec/octopus/serverspec/json/apisupportsspaces.json')
    ex_projectgroup_found_response = File.read('spec/octopus/serverspec/json/projectgroupsall.json')
    ex_spaces_all = File.read('spec/octopus/serverspec/json/spacesall.json')

    it "handles project group found" do
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces-2/projectgroups/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_projectgroup_found_response, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_spaces_all, headers: {})


      pg = OctopusDeployProjectGroup.new("https://octopus.example.com", "API-1234567890", "Octopus Projects", "Spaces-2")
      expect(pg.exists?).to be true

      pg_by_name = OctopusDeployProjectGroup.new("https://octopus.example.com", "API-1234567890", "Octopus Projects", nil, "Octopus")
      expect(pg_by_name.exists?).to be true
    end

    ex_projectgroup_notfound_response = File.read('spec/octopus/serverspec/json/projectgroupsall.json')

    it "handles projectgroup not found" do
      stub_request(:get, "https://octopus2.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus2.example.com/api/Spaces-1/projectgroups/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_projectgroup_notfound_response, headers: {})

      wp = OctopusDeployProjectGroup.new("https://octopus2.example.com", "API-0987654321", "Nonexistent projectgroup")
      expect(wp.exists?).to be false
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
      stub_request(:get, "https://octopus2.example.com/api/Spaces-1/projectgroups/all?api-key=API-0987654321").
          to_return(status: 200, body: ex_projectgroup_notfound_response, headers: {})


      wp = OctopusDeployProjectGroup.new("https://octopus2.example.com", "API-0987654321", "Octopus Projects", "Spaces-1")
      expect(wp.has_description?("This is a group of Octopus-related Projects")).to be true
    end

  end

end 