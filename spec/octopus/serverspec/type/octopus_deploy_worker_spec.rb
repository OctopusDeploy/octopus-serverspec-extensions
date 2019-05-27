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
    expect { OctopusDeployTentacle.new("https://someserver.com", "API-someapikey", "Worker1") }.
        to raise_error(/tentacle\.exe/)
  end
end