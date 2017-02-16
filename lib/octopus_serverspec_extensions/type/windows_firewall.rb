require 'serverspec'
require 'serverspec/type/base'

module Serverspec::Type
  class WindowsFirewall < Base

    def initialize
      @runner = Specinfra::Runner
    end

    def has_open_port?(port)
      command_result = @runner.run_command("$portFilter = (Get-NetFirewallPortFilter | Where-Object { $_.LocalPort -Eq #{port} -and $_.Protocol -eq 'TCP' }); if ($null -eq $portfilter) { return $false } ; $rule = Get-NetFirewallRule -AssociatedNetFirewallPortFilter $portfilter; \"$($rule.Enabled)|$($rule.PrimaryStatus)\"")
      command_result.stdout.gsub(/\n/, '') == "True|OK"
    end

    def enabled?
      command_result = @runner.run_command("(get-service MpsSvc).Status")
      command_result.stdout.gsub(/\n/, '') == "Running"
    end

    def to_s
      "Windows Firewall"
    end

  end

  def windows_firewall
    WindowsFirewall.new
  end
end

include Serverspec::Type
