# Octopus::Serverspec::Extensions

[![Gem Version](https://badge.fury.io/rb/octopus-serverspec-extensions.svg)](https://badge.fury.io/rb/octopus-serverspec-extensions)

SeverSpec extensions for Windows, adding support for chocolatey packages, npm packages, service accounts and more.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'octopus-serverspec-extensions'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install octopus-serverspec-extensions

## Example Usage

```
describe octopus_deploy_tentacle("https://myoctopus.dns", ENV['OctopusApiKey'], "Tentacle") do
  it { should exist }
  it { should be_registered_with_the_server }
  it { should be_online }
  it { should be_listening_tentacle }
  it { should be_in_environment('Production') }
  it { should have_role('my-application-role') }
  it { should have_policy('Production Cloud Target Policy') }
end
```

## Types

`octopus_deploy_account`

Describes an Octopus Account resource - an AWS, Azure, or SSH account [docs](doc/octopus_deploy_account.md)

`octopus_deploy_environment`

Describes an Octopus Environment Resource [docs]()

`octopus_deploy_project_group`

Describes an Octopus Project Group Resource

`octopus_deploy_smtp_config`

Describes Octopus Server-Level SMTP Configuration

`octopus_deploy_team`

Describes Octopus Team (or User Group)

`octopus_deploy_tentacle`

Describes the state of a Tentacle agent

`octopus_deploy_user`

Describes a User login account

`octopus_deploy_worker`

Describes the Worker agent resource

`octopus_deploy_worker_pool`

Describes a Pool of Worker agents

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/octopus-deploy/octopus-serverspec-extensions.


## License

The gem is available as open source under the terms of the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0).

