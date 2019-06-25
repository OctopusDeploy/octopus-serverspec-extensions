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
```

#### Matchers

| Matcher | Description |
|:--------|:------------|