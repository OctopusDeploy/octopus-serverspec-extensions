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

```ruby
octopus_deploy_space([url, apikey], space_name)
octopus_space([url, apikey], space_name)
```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| exist | test for existence of a given space |
| be_default | Tests if this space is the default space |
| have_running_task_queue | tests if the queue for this space is disabled |
