require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployWorker do

  let(:runner) { double ("runner")}

  it "throws if `serverUrl` not supplied" do
    allow_any_instance_of(OctopusDeployWorker).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return(nil)
    allow_any_instance_of(OctopusDeployWorker).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return(nil)

    expect { OctopusDeployWorker.new(nil, "someapikey", "Worker1") }.
        to raise_error(/credentials invalid/)
  end

  it "throws if `apiKey` not supplied" do
    allow_any_instance_of(OctopusDeployWorker).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return(nil)
    allow_any_instance_of(OctopusDeployWorker).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return(nil)

    expect { OctopusDeployWorker.new("https://someserver.com", nil, "Worker1") }.
        to raise_error(/credentials invalid/)
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
    ex_spaces_all = get_api_example('/api/spaces/all')
    before(:each) do
      allow(File).to receive(:exists?).and_return(true)
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_supports_spaces, headers: {})
      stub_request(:get, "https://octopus.example.com/api/Spaces/all?api-key=API-1234567890").
          to_return(status: 200, body: ex_spaces_all, headers: {})

    end

    context ".registered_with_the_server" do
      it "returns false if the worker is not registered to the server" do
        allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("4BD377BF21A882251B9A5A492889555377A58E07")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/workers/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_response, headers: {})

        nonexistent_worker = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX').in_space('Default')
        expect(nonexistent_worker.registered_with_the_server?).to be false
      end

      it "returns true if the tentacle is registered to the server" do
        allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("D7E6B4CEEE0960CE944B92432605A2BAF14C7405")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/workers/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_response, headers: {})

        existent_worker = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX').in_space('Default')
        expect(existent_worker.registered_with_the_server?).to be true
      end

      it "can resolve a known worker in space 2" do
        allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("C1CCB36BA1FE29A890605FD00C08FFEDE4118A38")
        stub_request(:get, "https://octopus.example.com/api/Spaces-2/workers/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_response_two, headers: {})

        existent_worker = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX2').in_space('Octopus')
        expect(existent_worker.registered_with_the_server?).to be true
      end
    end

    context ".online" do
      it "returns true for a worker that's known to be online" do
        allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("D7E6B4CEEE0960CE944B92432605A2BAF14C7405")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/workers/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_response, headers: {})

        existent_worker = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX').in_space('Default')
        expect(existent_worker.online?).to be true
      end
    end

    context ".has_endpoint" do

      it "can detect an endpoint correctly" do
        allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("D7E6B4CEEE0960CE944B92432605A2BAF14C7405")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/workers/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_response, headers: {})
        existent_worker= OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX').in_space('Default')
        expect(existent_worker.has_endpoint?("https://vagrantbox:10937/")).to be true
      end

      it "can detect an incorrect endpoint" do
        allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("D577F1B4D70D24E1356EF5B75CD7542BB049A073")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/workers/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_response, headers: {})
        incorrect_worker = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'ListeningTentacle').in_space('Default')
        expect(incorrect_worker.has_endpoint?("https://vagrantbox:10937/")).to be false
      end

      it "can handle null endpoint from a polling tentacle" do
        allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("3F098A11B3F8D42C228A3DB03A902BA92BE8514A")
        stub_request(:get, "https://octopus.example.com/api/Spaces-1/workers/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_response, headers: {})

        polling_worker = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX-POLLING').in_space('Default')
        expect(polling_worker.has_endpoint?("https://vagrant-1803:10933/")).to be false
      end
    end
  end

  context "server does not support spaces" do
    ex_does_not_support_spaces = get_api_example('/api/2018.7.9')

    before(:each) do
      allow(File).to receive(:exists?).and_return(true)
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: ex_does_not_support_spaces, headers: {})
    end

    context ".registered_with_the_server" do
      it "returns false if the worker is not registered to the server" do
        allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("B6465C274B07791E096915B3C6F035980D8FFDD9")
        stub_request(:get, "https://octopus.example.com/api/workers/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_response, headers: {})

        nonexistent_worker = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'WorkerThatDoesNotExist')
        expect(nonexistent_worker.registered_with_the_server?).to be false
      end

      it "returns true if the worker is registered to the server" do
        allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("D7E6B4CEEE0960CE944B92432605A2BAF14C7405")
        stub_request(:get, "https://octopus.example.com/api/workers/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_response, headers: {})

        existent_worker = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX')
        expect(existent_worker.registered_with_the_server?).to be true
      end
    end

    context ".online" do
      it "returns true for a machine that's known to be online" do
        allow_any_instance_of(OctopusDeployWorker).to receive(:`).and_return("D7E6B4CEEE0960CE944B92432605A2BAF14C7405")
        stub_request(:get, "https://octopus.example.com/api/workers/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_response, headers: {})

        existent_worker = OctopusDeployWorker.new('https://octopus.example.com', 'API-1234567890', 'VAGRANTBOX')
        expect(existent_worker.online?).to be true
      end
    end
  end
end