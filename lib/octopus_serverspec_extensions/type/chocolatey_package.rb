require 'serverspec'
require 'serverspec/type/base'

module Serverspec::Type
  class ChocolateyPackage < Base

    def initialize(name)
      @name = name
      @runner = Specinfra::Runner
    end

    def installed?(provider, version)
      command_result = @runner.run_command("choco list -l -r #{name}")

      software = command_result.stdout.gsub("\r\n", "\n").split("\n").each_with_object({}) do |s, h|
        v, k = s.split('|')
        h[String(v).strip.downcase] = String(k).strip.downcase
        h
      end

      if (version.nil?)
        !software[name.downcase].nil?
      else
        software[name.downcase] == version
      end
    end
  end

  def chocolatey_package(name)
    ChocolateyPackage.new(name)
  end
end

include Serverspec::Type