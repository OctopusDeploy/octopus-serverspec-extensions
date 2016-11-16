RSpec::Matchers.define :have_linux_line_endings do
  match do |file|
    !file.content.include?("\r\n")
  end
end
