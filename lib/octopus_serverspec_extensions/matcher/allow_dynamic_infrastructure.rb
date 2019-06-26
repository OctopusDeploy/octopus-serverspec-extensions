RSpec::Matchers.define :allow_dynamic_infrastructure do
  match do |env|
    env.allow_dynamic_infrastructure? == true
  end

  failure_message do |env|
    "Expected Environment '#{env.environment_name}' to allow dynamic infrastructure, but it didn't"
  end

  failure_message_when_negated do |env|
    "Expected Environment '#{env.environment_name}' not to allow dynamic infrastructure, but it did"
  end
end