# octopus_deploy_space

Describes an Octopus Deploy [Space](https://octopus.com/docs/administration/spaces) resource.

## Example

```ruby
describe octopus_deploy_space('Team Phoenix') do
  it { should exist }
  it { should have_running_task_queue }
end
```

#### Type

This type can be instantiated in several ways, depending on [how you authenticate](authentication.md).

```ruby
octopus_deploy_space(server_url, api_key, space_name)  # url and apikey provided
octopus_deploy_space(space_name)                       # using environment variables
octopus_space(server_url, api_key, space_name)
octopus_space(space_name)                              # shorthand
```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| exist | test for existence of a given space |
| be_default | Tests if this space is the default space |
| have_running_task_queue | tests if the queue for this space is disabled |
| have_description(description) | tests if the space has the specified description |
