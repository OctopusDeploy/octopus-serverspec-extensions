require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeployWorkerPool do

    let(:runner) { double ("runner")}

    it "throws if `serverUrl` not supplied" do
        expect { OctopusDeployWorkerPool.new(nil, "someapikey", "my new worker pool") }.
            to raise_error(/serverUrl/)
    end

    it "throws if `apiKey` not supplied" do
        expect { OctopusDeployWorkerPool.new("https://someserver.com", nil, "my new worker pool") }.
            to raise_error(/apiKey/)
    end

    it "throws if `workerPoolName` not supplied" do
        expect { OctopusDeployWorkerPool.new("https://someserver.com", "API-kllkjhasdkljhasdfkjsafd", nil) }.
            to raise_error(/worker_pool_name/)
    end

    examplejsonpath = 'spec/octopus/serverspec/json/workerpoolsall.json'
    examplejson = File.open(examplejsonpath)

    it "handles worker pool found" do
        stub_request(:get, "https://octopus.example.com/api/workerpools/all?api-key=API-1234567890").
            to_return(status: 200, body: examplejson, headers: {})
        wp = OctopusDeployWorkerPool.new("https://octopus.example.com", "API-1234567890", "Second Worker Pool")
        expect(wp.exists?).to be true
    end

    examplejson2 = File.open(examplejsonpath) # you get an IOError if you reuse the earlier File.open()

    it "handles worker pool not found" do
        stub_request(:get, "https://octopus2.example.com/api/workerpools/all?api-key=API-0987654321").
            to_return(status: 200, body: examplejson2, headers: {})
        wp = OctopusDeployWorkerPool.new("https://octopus2.example.com", "API-0987654321", "Ninth Worker Pool")
        expect(wp.exists?).to be false
    end

    it "doesn't crash badly if handed a bad URL" do
        stub_request(:get, "https://octopus.example.com/api/workerpools/all?api-key=API-1234567890").to_raise(StandardError)

        expect { OctopusDeployWorkerPool.new("https://octopus.example.com", "API-1234567890", "Second Worker Pool") }.to raise_error
    end

end
