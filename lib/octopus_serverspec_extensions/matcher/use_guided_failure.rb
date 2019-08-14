RSpec::Matchers.define :use_guided_failure do
  match do |env|
    env.use_guided_failure? == true
  end

  failure_message do |env|
    "Expected Environment '#{env.environment_name}' to use guided failure mode, but it didn't"
  end

  failure_message_when_negated do |env|
    "Expected Environment '#{env.environment_name}' not to use guided failure mode, but it did"
  end
end