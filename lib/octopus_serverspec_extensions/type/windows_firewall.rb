require 'serverspec'
require 'serverspec/type/base'

module Serverspec::Type
  class WindowsFirewall < Base

    def initialize
      @runner = Specinfra::Runner
    end

    def has_open_port?(port)
      command_result = @runner.run_command("((New-Object -comObject HNetCfg.FwPolicy2).rules | where-object { $_.LocalPorts -eq #{port} -and $_.Action -eq 1}).Enabled")
      command_result.stdout.gsub(/\n/, '') == "True"
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
