# octopus_deploy_upgrade_config

Tests the server-wide upgrade configuration. This can be found in the UI at Configuration->Settings->Updates & Usage Telemetry

## Example

```ruby
describe octopus_deploy_upgrade_config do
  
end
```

#### Type

This type can be instantiated in several ways, depending on [how you authenticate](authentication.md).

```ruby
octopus_deploy_upgrade_config(server_url, api_key)  # url and apikey provided
octopus_deploy_upgrade_config                       # using environment vars
octopus_upgrade_config(server_url, api_key)         # shorthand
octopus_upgrade_config                              # shorthand, using env vars
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