RSpec::Matchers.define :have_windows_line_endings do
  match do |file|
    file.content.include?("\r\n")
  end

  failure_message do |file|
    "Expected file '#{file.name}' to have windows line endings, but it didn't"
  end

  failure_message_when_negated do |file|
    "Expected file '#{file.name}' to not have windows line endings, but it did"
  end
end
