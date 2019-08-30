# octopus_deploy_upgrade_config

Tests the server-wide upgrade configuration. This can be found in the UI at Configuration->Settings->Updates & Usage Telemetry.

## Example

```ruby
describe octopus_deploy_upgrade_config do
  it { should include_statistics }
  it { should never_show_notifications }  
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
| should have_notification_mode(mode) | Tests if the Notification mode is set to the given value. Possible values: ['AlwaysShow', 'ShowOnlyMajorMinor', 'NeverShow'] |
| should never_show_notifications | equivalent to `should_have_notification_mode('NeverShow')` | 
| should always_show_notifications | equivalent to `should_have_notification_mode('AlwaysShow')` | 
| should show_major_minor_notifications | equivalent to `should_have_notification_mode('ShowOnlyMajorMinor')` |
| should include_statistics | Tests if the IncludeStatistics setting is set to `true` |
| should allow_checking | Tests if the AllowChecking setting is set to `true` |  