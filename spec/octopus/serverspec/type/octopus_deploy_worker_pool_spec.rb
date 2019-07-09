require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployWorkerPool do

    let(:runner) { double ("runner")}

    it "throws if `serverUrl` not supplied" do
        allow_any_instance_of(OctopusDeployWorkerPool).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return(nil)
        allow_any_instance_of(OctopusDeployWorkerPool).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return(nil)

        expect { OctopusDeployWorkerPool.new(nil, "someapikey", "my new worker pool") }.
            to raise_error(/serverUrl/)
    end

    it "throws if `apiKey` not supplied" do
        allow_any_instance_of(OctopusDeployWorkerPool).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return(nil)
        allow_any_instance_of(OctopusDeployWorkerPool).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return(nil)

        expect { OctopusDeployWorkerPool.new("https://someserver.com", nil, "my new worker pool") }.
            to raise_error(/apiKey/)
    end

    it "throws if `workerPoolName` not supplied" do
        expect { OctopusDeployWorkerPool.new("https://someserver.com", "API-kllkjhasdkljhasdfkjsafd", nil) }.
            to raise_error(/worker_pool_name/)
    end

    example_worker_pool_response = get_api_example('/api/workerpools/all')

    it "handles worker pool found" do
        stub_request(:get, "https://octopus.example.com/api/workerpools/all?api-key=API-1234567890").
            to_return(status: 200, body: example_worker_pool_response, headers: {})
        wp = OctopusDeployWorkerPool.new("https://octopus.example.com", "API-1234567890", "Second Worker Pool")
        expect(wp.exists?).to be true
    end

    it "handles worker pool not found" do
        stub_request(:get, "https://octopus2.example.com/api/workerpools/all?api-key=API-0987654321").
            to_return(status: 200, body: example_worker_pool_response, headers: {})
        wp = OctopusDeployWorkerPool.new("https://octopus2.example.com", "API-0987654321", "Ninth Worker Pool")
        expect(wp.exists?).to be false
    end

    it "doesn't crash badly if handed a bad URL" do
        stub_request(:get, "https://nonexistentdomain.com/api/workerpools/all?api-key=API-1234567890").to_raise(SocketError)

        expect { OctopusDeployWorkerPool.new("https://nonexistentdomain.com", "API-1234567890", "Second Worker Pool") }.to raise_error(StandardError)
    end
end
