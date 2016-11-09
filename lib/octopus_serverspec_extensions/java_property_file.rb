require 'serverspec'
require 'serverspec/type/base'

module Serverspec::Type
  class JavaPropertyFile < Base

    def initialize(name)
      @name = name
      @runner = Specinfra::Runner
    end

    def has_property?(propertyName, propertyValue)
      properties = {}
      IO.foreach(@name) do |line|
          properties[$1.strip] = $2 if line =~ /([^=]*)=(.*)/
      end

      properties[propertyName] == propertyValue
    end
  end

  def java_property_file(name)
    JavaPropertyFile.new(name)
  end
end

include Serverspec::Type