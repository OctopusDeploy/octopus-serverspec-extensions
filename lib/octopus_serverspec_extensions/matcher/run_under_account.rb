RSpec::Matchers.define :run_under_account do |account_name|
  match do |service|
    @runner = Specinfra::Runner
    command_result = @runner.run_command("$ProgressPreference = 'SilentlyContinue'; (Get-WmiObject Win32_Service | Where-Object {$_.Name -eq '#{service.name}'}).StartName -eq '#{account_name}'")
    command_result.stdout.strip == 'True'
  end

  failure_message do |service|
    command_result = @runner.run_command("$ProgressPreference = 'SilentlyContinue'; (Get-WmiObject Win32_Service | Where-Object {$_.Name -eq '#{service.name}'}).StartName")
    "Expected service '#{service.name}' to be running under '#{account_name}' but was running under '#{command_result.stdout.strip}'"
  end

  failure_message_when_negated do |service|
    command_result = @runner.run_command("$ProgressPreference = 'SilentlyContinue'; (Get-WmiObject Win32_Service | Where-Object {$_.Name -eq '#{service.name}'}).StartName")
    "Expected service '#{service.name}' to not be running under '#{account_name}' but was running under '#{command_result.stdout.strip}'"
  end
end
