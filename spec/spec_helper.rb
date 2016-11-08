$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "octopus_serverspec_extensions"

set :backend, :cmd
set :os, :family => 'windows'
