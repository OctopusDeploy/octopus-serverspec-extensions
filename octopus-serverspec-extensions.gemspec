# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopus_serverspec_extensions/version'

Gem::Specification.new do |spec|
  spec.name          = "octopus-serverspec-extensions"
  spec.version       = OctopusServerSpecExtensions::VERSION
  spec.authors       = ["Matt Richardson"]
  spec.email         = "devops@octopus.com"
  spec.summary       = %q{ServerSpec extensions for Octopus Deploy}
  spec.description   = %q{ServerSpec extensions for Octopus Deploy, adds support for Octopus Deploy objects and including some common windows objects.}
  spec.homepage      = "https://github.com/octopus-deploy/octopus-serverspec-extensions"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "serverspec", "~> 2"
  spec.add_dependency "specinfra", "~> 2"
  spec.add_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'json', '~> 2.3.0'

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", ">= 13"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "rspec-teamcity", "~> 1"
  spec.add_development_dependency "webmock", "~> 3"

end
