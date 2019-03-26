# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopus_serverspec_extensions/version'

Gem::Specification.new do |spec|
  spec.name          = "octopus-serverspec-extensions"
  spec.version       = OctopusServerSpecExtensions::VERSION
  spec.authors       = ["Matt Richardson"]
  spec.email         = "devops@octopus.com"
  spec.summary       = %q{SeverSpec extensions for Windows}
  spec.description   = %q{SeverSpec extensions for Windows, adding support for chocolatey packages, npm packages, service accounts and more.}
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
  spec.add_dependency 'json', '~> 2.1'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-teamcity", "~> 0.0.1"
  spec.add_development_dependency "webmock", "~> 3.5.1"

end
