require 'serverspec'
require 'serverspec/type/base'

module Serverspec::Type
  class NpmPackage < Base

    def initialize(name)
      @name = name
      @runner = Specinfra::Runner
    end

    def installed?(provider, version)
      command_result = @runner.run_command("npm list -g #{name}")

      software = command_result.stdout.split("\n").each_with_object({}) do |s, h|
        if s.include? "@"
          package_name, package_version = s.split('@')
          package_name = package_name.gsub(/.*? /, '')
          h[String(package_name).strip.downcase] = String(package_version).strip.downcase
        end
        h
      end

      if (version.nil?)
        !software[name.downcase].nil?
      else
        software[name.downcase] == version
      end
    end
  end

  def npm_package(name)
    NpmPackage.new(name)
  end
end

include Serverspec::Type