require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployWorker do

  let(:runner) { double ("runner")}

  it "throws if `serverUrl` not supplied" do
    expect { OctopusDeployWorker.new(nil, "someapikey", "Worker1") }.
        to raise_error(/serverUrl/)
  end

  it "throws if `apiKey` not supplied" do
    expect { OctopusDeployWorker.new("https://someserver.com", nil, "Worker1") }.
        to raise_error(/apiKey/)
  end

  it "throws if the tentacle executable doesn't exist" do
    allow(File).to receive(:exists?).and_return(false)
    expect { OctopusDeployWorker.new("https://someserver.com", "API-someapikey", "Worker1") }.
        to raise_error(/tentacle\.exe/)
  end

  example_worker_response = get_api_example('/api/workers/all')
  example_worker_response_two = get_api_example('/api/Spaces-2/workers/all')

  context "Server supports spaces" do

    ex_supports_spaces = get_api_example('/api/2019.4.5')
    before(:each) do
      allow(File).to receive(:exists?).and_return(true)
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
    end

    it "returns false if the worker is not registered to the server" do
      allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("4BD377BF21A882251B9A5A492889555377A58E07")
      stub_request(:get, "https://octopus.example.com/api/Spaces-1/workers/all?api-key=API-1234567890").
          to_return(status: 200, body: example_worker_response, headers: {})

      nt = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX')
      expect(nt.registered_with_the_server?).to be false
    end

    it "returns true if the tentacle is registered to the server" do
      allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("D7E6B4CEEE0960CE944B92432605A2BAF14C7405")
      stub_request(:get, "https://octopus.example.com/api/Spaces-1/workers/all?api-key=API-1234567890").
          to_return(status: 200, body: example_worker_response, headers: {})

      nt = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX')
      expect(nt.registered_with_the_server?).to be true
    end

    it "can resolve a worker in space 2" do
      allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("C1CCB36BA1FE29A890605FD00C08FFEDE4118A38")
      stub_request(:get, "https://octopus.example.com/api/Spaces-2/workers/all?api-key=API-1234567890").
          to_return(status: 200, body: example_worker_response_two, headers: {})

      nt = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX2', 'Spaces-2')
      expect(nt.registered_with_the_server?).to be true
    end

  end
end