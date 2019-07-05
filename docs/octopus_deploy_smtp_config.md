# octopus_deploy_smtp_config

Tests the server-wide SMTP configuration. This can be found in the Octopus Portal under Configuration -> SMTP

## Example

```ruby
describe octopus_deploy_smtp_config do
  it { should be_configured }
  it { should have_from_address('hello@example.com') }
  it { should be_using_credentials('myusername') }
  it { should_not be_using_credentials('myspecialusername') }
  it { should be_on_port(25) }
  it { should be_on_host('smtp.example.com')}
  it { should be_using_ssl }
end
```

#### Type

This type can be instantiated in several ways, depending on [how you authenticate](authentication.md).

```ruby
octopus_deploy_smtp_config(server_url, api_key)  # url and apikey provided
octopus_deploy_smtp_config                       # using environment vars
octopus_smtp_config(server_url, api_key)         # shorthand
octopus_smtp_config
```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| should be_configured | Tests if the SMTP configuration has been set
| should be_on_host(host) | Tests the "SMTP Host" field |
| should be_on_port(port) | Tests the "SMTP Port" field |
| should be_using_ssl | Tests the "Use SSL/TLS" field |
| should have_from_address(address) | Tests the "From Address" field |
| should be_using_credentials(username) | Tests the "Credentials" field (username only) |
