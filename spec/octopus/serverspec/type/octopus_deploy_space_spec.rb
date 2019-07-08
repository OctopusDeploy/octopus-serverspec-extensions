require 'spec_helper'
require 'webmock/rspec'

describe OctopusDeploySpace do

  let(:runner) { double ("runner")}

  example_spaces_response = get_api_example('/api/spaces/all')
  example_supports_spaces = get_api_example('/api/2019.4.5')

  before(:each) do
    stub_request(:get, "https://octopus.example.com/api/Spaces/all?api-key=API-1234567890").
        to_return(status: 200, body: example_spaces_response, headers: {})
    stub_request(:get, "https://octopus.example.com/api/").
        to_return(status: 200, body: example_supports_spaces, headers: {})
  end

  it "can use the environment vars instead of literal args" do
    allow_any_instance_of(OctopusDeploySpace).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return("API-1234567890")
    allow_any_instance_of(OctopusDeploySpace).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return("https://octopus.example.com")

    my_space = OctopusDeploySpace.new(nil, nil, "Octopus")
    expect( my_space.exists?).to be true
  end

  it 'should detect a known non-existent space' do
    my_space = OctopusDeploySpace.new('https://octopus.example.com/', 'API-1234567890', "NonExistent")
    expect( my_space.exists?).to be false
  end

  it 'should detect a non-running task queue' do
    my_space = OctopusDeploySpace.new('https://octopus.example.com/', 'API-1234567890', "Stopped")
    expect( my_space.has_running_task_queue?).to be false
  end

  it 'should detect a running task queue' do
    allow_any_instance_of(OctopusDeploySpace).to receive(:get_env_var).with('OCTOPUS_CLI_API_KEY').and_return("API-1234567890")
    allow_any_instance_of(OctopusDeploySpace).to receive(:get_env_var).with('OCTOPUS_CLI_SERVER').and_return("https://octopus.example.com")


    my_space = OctopusDeploySpace.new(nil, nil, "Octopus")
    expect( my_space.has_running_task_queue?).to be true
  end

  it 'should detect if a space is the default' do
    my_space = OctopusDeploySpace.new('https://octopus.example.com/', 'API-1234567890', "Default")
    expect( my_space.default?).to be true
  end

  it 'should detect if a space is not the default' do
    my_space = OctopusDeploySpace.new('https://octopus.example.com/', 'API-1234567890', "Octopus")
    expect( my_space.default?).to be false
  end

  it 'should detect a description' do
    my_space = OctopusDeploySpace.new('https://octopus.example.com/', 'API-1234567890', "Octopus")
    expect( my_space.has_description?('A Space for Octopus-related Projects')).to be true
  end

  context 'does not support spaces' do
    it "Should raise if we don't support spaces" do

      example_does_not_support_spaces = get_api_example('/api/2018.7.9')
      stub_request(:get, "https://octopus.example.com/api/").
          to_return(status: 200, body: example_does_not_support_spaces, headers: {})

      my_space = OctopusDeploySpace.new('https://octopus.example.com/', 'API-1234567890', "Default")
      expect{ my_space.default? }.to raise_error(/Server does not support Spaces/)
    end
  end
end
