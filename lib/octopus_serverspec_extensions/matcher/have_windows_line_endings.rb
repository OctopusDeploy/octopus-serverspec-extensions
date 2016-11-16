RSpec::Matchers.define :have_windows_line_endings do
  match do |file|
    file.content.include?("\r\n")
  end
end
