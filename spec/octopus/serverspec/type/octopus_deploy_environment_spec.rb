require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployEnvironment do

    let(:runner) { double ("runner")}

    it "throws if `serverUrl` not supplied" do
        expect { OctopusDeployEnvironment.new(nil, "someapikey", "my new environment") }.
            to raise_error(/serverUrl/)
    end

    it "throws if `apiKey` not supplied" do
        expect { OctopusDeployEnvironment.new("https://someserver.com", nil, "my new environment") }.
            to raise_error(/apiKey/)
    end

    it "throws if `environmentname` not supplied" do
        expect { OctopusDeployEnvironment.new("https://someserver.com", "API-kllkjhasdkljhasdfkjsafd", nil) }.
            to raise_error(/environment_name/)
    end

    example_environment_found_response = File.open('spec/octopus/serverspec/json/envfound.json')

    it "handles environment found" do
        stub_request(:get, "https://octopus.example.com/api/environments?name=The-Env&api-key=API-1234567890").
            to_return(status: 200, body: example_environment_found_response, headers: {})
        ef = OctopusDeployEnvironment.new("https://octopus.example.com", "API-1234567890", "The-Env")
        expect(ef.exists?).to be true
    end

    example_environment_note_found_response = File.open('spec/octopus/serverspec/json/envnotfound.json') # you get an IOError if you reuse the earlier File.open()

    it "handles environment not found" do
        stub_request(:get, "https://octopus2.example.com/api/environments?name=Not-an-Env&api-key=API-0987654321").
            to_return(status: 200, body: example_environment_note_found_response, headers: {})
        enf = OctopusDeployEnvironment.new("https://octopus2.example.com", "API-0987654321", "Not-an-Env")
        expect(enf.exists?).to be false
    end

    it "doesn't crash badly if handed a bad URL" do
        stub_request(:get, "https://nonexistentdomain.com/api/environments?name=The-Env&api-key=API-1234567890").to_raise(SocketError)

        expect { OctopusDeployEnvironment.new("https://nonexistentdomain.com", "API-1234567890", "The-Env") }.to raise_error(StandardError)
    end

end
