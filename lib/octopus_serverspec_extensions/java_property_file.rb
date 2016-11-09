require 'serverspec'
require 'serverspec/type/base'

module Serverspec::Type
  class JavaPropertyFile < Base

    def initialize(name)
      @name = name
      @runner = Specinfra::Runner
    end

    def have_property?(propertyName, propertyValue)
      properties = {}
      IO.foreach(file) do |line|
        properties[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~ /([^=]*)=(.*)/
      end

      properties[propertyName] == propertyValue
    end
  end

  def java_property_file(name)
    JavaPropertyFile.new(name)
  end
end

include Serverspec::Type