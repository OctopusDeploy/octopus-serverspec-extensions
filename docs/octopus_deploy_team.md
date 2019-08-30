# octopus_deploy_team

Describes an Octopus Deploy [Team](https://octopus.com/docs/administration/managing-users-and-teams) resource. 

## Example

```ruby
describe octopus_team('Super Ninja Developer Squad') do
  it { should exist }
end

```
#### Type

```ruby
octopus_deploy_team([url, api_key], team_name)
octopus_team([url, api_key], team_name)
octopus_team([url, api_key], team_name).in_space(space_name)

```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| should exist | Checks for existence of a team with the given name |