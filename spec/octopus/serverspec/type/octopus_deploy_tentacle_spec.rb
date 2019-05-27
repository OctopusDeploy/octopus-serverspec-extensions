require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployTentacle do

  let(:runner) { double ("runner") }

  it "throws if `serverUrl` not supplied" do
    expect { OctopusDeployTentacle.new(nil, "API-someapikey", "Tentacle1") }.
        to raise_error(/serverUrl/)
  end

  it "throws if `apiKey` not supplied" do
    expect { OctopusDeployTentacle.new("https://someserver.com", nil, "Tentacle1") }.
        to raise_error(/apiKey/)
  end

  it "throws if the tentacle executable doesn't exist" do
    allow(File).to receive(:exists?).and_return(false)
    expect { OctopusDeployTentacle.new("https://someserver.com", "API-someapikey", "Tentacle1") }.
        to raise_error(/tentacle\.exe/)
  end

  example_tentacle_response = get_api_example('/api/machines/all')

  context "Server supports spaces" do

    ex_supports_spaces = get_api_example('/api/2019.4.5')

    # .registered_with_the_server()
    it "returns false if the tentacle is not registered to the server" do
      allow(File).to receive(:exists?).and_return(true)
      allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("D7E6B4CEEE0960CE944B92432605A2BAF14C7405")
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
          to_return(status: 200, body: example_tentacle_response, headers: {})

      nt = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleThatDoesNotExist')
      expect(nt.registered_with_the_server?).to be false
    end

    it "returns true if the tentacle is registered to the server" do
      allow(File).to receive(:exists?).and_return(true)
      allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("4BD377BF21A882251B9A5A492889555377A58E07")
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
          to_return(status: 200, body: example_tentacle_response, headers: {})

      nt = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleWithThumbprintWithoutAutoRegister')
      expect(nt.registered_with_the_server?).to be true
    end

    # .online?
    it "returns true for a machine that's known to be online" do
      allow(File).to receive(:exists?).and_return(true)
      allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("4BD377BF21A882251B9A5A492889555377A58E07")
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
          to_return(status: 200, body: example_tentacle_response, headers: {})

      nt = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleWithThumbprintWithoutAutoRegister')
      expect(nt.online?).to be true
    end


  end

  context "server does not support spaces" do
    ex_does_not_support_spaces = get_api_example('/api/2018.7.9')

    # .registered_with_the_server()
    it "returns false if the tentacle is not registered to the server" do
      allow(File).to receive(:exists?).and_return(true)
      allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("D7E6B4CEEE0960CE944B92432605A2BAF14C7405")
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/machines/all?api-key=API-1234567890").
          to_return(status: 200, body: example_tentacle_response, headers: {})

      nt = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleThatDoesNotExist')
      expect(nt.registered_with_the_server?).to be false
    end

    it "returns true if the tentacle is registered to the server" do
      allow(File).to receive(:exists?).and_return(true)
      allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("4BD377BF21A882251B9A5A492889555377A58E07")
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/machines/all?api-key=API-1234567890").
          to_return(status: 200, body: example_tentacle_response, headers: {})

      nt = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleWithThumbprintWithoutAutoRegister')
      expect(nt.registered_with_the_server?).to be true
    end

  end


end