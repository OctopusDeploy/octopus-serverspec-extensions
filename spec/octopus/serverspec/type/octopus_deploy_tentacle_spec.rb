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

  it "does not throw if the tentacle executable doesn't exist" do
    allow(File).to receive(:exists?).and_return(false)
    tentacle = OctopusDeployTentacle.new("https://someserver.com", "API-someapikey", "Tentacle1")
    expect(tentacle.exists?).to be false
  end

  example_tentacle_response = get_api_example('/api/machines/all')

  context "Server supports spaces" do

    ex_supports_spaces = get_api_example('/api/2019.4.5')
    before(:each) do
      allow(File).to receive(:exists?).and_return(true)
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
    end

    context ".registered_with_the_server" do
      it "returns false if the tentacle is not registered to the server" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("D7E6B4CEEE0960CE944B92432605A2BAF14C7405")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        nonexistent_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleThatDoesNotExist')
        expect(nonexistent_tentacle.registered_with_the_server?).to be false
      end

      it "returns true if the tentacle is registered to the server" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("4BD377BF21A882251B9A5A492889555377A58E07")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        unregistered_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleWithThumbprintWithoutAutoRegister')
        expect(unregistered_tentacle.registered_with_the_server?).to be true
      end
    end

    context ".online" do
      it "returns true for a machine that's known to be online" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("4BD377BF21A882251B9A5A492889555377A58E07")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        unregistered_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleWithThumbprintWithoutAutoRegister')
        expect(unregistered_tentacle.online?).to be true
      end
    end

    context ".listening_tentacle" do
      it "returns true for a known listening tentacle" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("D577F1B4D70D24E1356EF5B75CD7542BB049A073")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})
        listening_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacle')
        expect(listening_tentacle.listening_tentacle? ).to be true
      end

      it "returns false for a known polling tentacle" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("2926388491F714807F0B181B38DBB9AA1EF946DC")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        polling_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'PollingTentacle')
        expect(polling_tentacle.listening_tentacle?).to be false
      end
    end

    context ".polling_tentacle" do
      it "returns true for a known polling tentacle" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("2926388491F714807F0B181B38DBB9AA1EF946DC")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        polling_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'PollingTentacle')
        expect(polling_tentacle.polling_tentacle?).to be true
      end

      it "returns false for a known listening tentacle" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("D577F1B4D70D24E1356EF5B75CD7542BB049A073")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})
        listening_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacle')
        expect(listening_tentacle.polling_tentacle?).to be false
      end
    end

    context ".has_tenant_tag" do
      it "can detect a tenant tag correctly" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("D577F1B4D70D24E1356EF5B75CD7542BB049A073")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})
        listening_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacle')
        expect(listening_tentacle.has_tenant_tag?("Hosting","Cloud")).to be true
      end

      it "can detect tenant tag missing" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("2926388491F714807F0B181B38DBB9AA1EF946DC")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        polling_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'PollingTentacle')
        expect(polling_tentacle.has_tenant_tag?("Hosting", "Cloud")).to be false
      end
    end

    context ".has_endpoint" do
      it "can detect an endpoint correctly" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("D577F1B4D70D24E1356EF5B75CD7542BB049A073")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})
        listening_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacle')
        expect(listening_tentacle.has_endpoint?("https://vagrant-1803:10933/")).to be true
      end

      it "can detect an incorrect endpoint" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("D577F1B4D70D24E1356EF5B75CD7542BB049A073")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})
        listening_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacle')
        expect(listening_tentacle.has_endpoint?("https://vagrant-1803:10935/")).to be false
      end

      it "can handle null endpoint from a polling tentacle" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("2926388491F714807F0B181B38DBB9AA1EF946DC")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        polling_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'PollingTentacle')
        expect(polling_tentacle.has_endpoint?("https://vagrant-1803:10933/")).to be false
      end
    end

    context ".has_role" do
      it "can detect a role correctly" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("D577F1B4D70D24E1356EF5B75CD7542BB049A073")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})
        listening_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacle')
        expect(listening_tentacle.has_role?("Listening-Tentacle")).to be true
      end

      it "can detect role missing" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("2926388491F714807F0B181B38DBB9AA1EF946DC")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        polling_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'PollingTentacle')
        expect(polling_tentacle.has_role?("Listening-Tentacle")).to be false
      end
    end
  end

  # if the spaces support works, then a subset of those tests for not-spaces
  # should be all that's required - as they both pass through the same code

  context "server does not support spaces" do
    ex_does_not_support_spaces = get_api_example('/api/2018.7.9')

    before(:each) do
      allow(File).to receive(:exists?).and_return(true)
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
    end

    context ".registered_with_the_server" do
      it "returns false if the tentacle is not registered to the server" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("D7E6B4CEEE0960CE944B92432605A2BAF14C7405")
        stub_request(:get, "https://octopus.example.com/api/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        nonexistent_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleThatDoesNotExist')
        expect(nonexistent_tentacle.registered_with_the_server?).to be false
      end

      it "returns true if the tentacle is registered to the server" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("4BD377BF21A882251B9A5A492889555377A58E07")
        stub_request(:get, "https://octopus.example.com/api/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        unregistered_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleWithThumbprintWithoutAutoRegister')
        expect(unregistered_tentacle.registered_with_the_server?).to be true
      end
    end

    context ".online" do
      it "returns true for a machine that's known to be online" do
        allow_any_instance_of(OctopusDeployTentacle).to receive(:`).and_return("4BD377BF21A882251B9A5A492889555377A58E07")
        stub_request(:get, "https://octopus.example.com/api/machines/all?api-key=API-1234567890").
            to_return(status: 200, body: example_tentacle_response, headers: {})

        unregistered_tentacle = OctopusDeployTentacle.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacleWithThumbprintWithoutAutoRegister')
        expect(unregistered_tentacle.online?).to be true
      end
    end
  end
end