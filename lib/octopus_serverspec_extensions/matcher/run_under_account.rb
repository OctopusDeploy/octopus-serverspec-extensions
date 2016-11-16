RSpec::Matchers.define :run_under_account do |account_name|
  match do |service|
    Backend::PowerShell::Command.new do
      exec "(Get-WmiObject win32_service | where-object { $_.Name -eq '#{service.name}' }).StartName -eq '#{account_name}"
    end
  end
end
