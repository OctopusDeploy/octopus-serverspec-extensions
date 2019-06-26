# octopus_deploy_environment

Models/Tests an Octopus Deploy [Environment](https://octopus.com/docs/infrastructure/environments) resource

## Example

```ruby
describe octopus_deploy_environment('Production').in_space('Team Octopus') do
  it { should exist }
end
```

#### Type

```ruby
octopus_deploy_environment([url, api_key], environment_name)
octopus_environment([url, api_key], environment_name)
octopus_environment([url, api_key], environment_name).in_space(spacename)

```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| should exist | Tests for the existence of a given Environment |
| should use_guided_failure | Tests if the Environment has the Use Guided Failure default applied |
| should allow_dynamic_infrastructure | Tests if the checkbox for [Allow Dynamic Infrastructure](https://octopus.com/docs/infrastructure/environments#enabling-dynamic-infrastructure) is checked |
 