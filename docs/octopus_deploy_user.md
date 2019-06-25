# octopus_deploy_user

Describes an Octopus Deploy User resource

## Example

```ruby
describe octopus_deploy_user('bobthedeveloper') do
  it { should exist }
  it { should be_active }
end

```

#### Type

```ruby
octopus_deploy_user([url, api_key], user_name)
octopus_user([url, api_key], user_name)
```

#### Matchers

| Matcher | Description |
|:--------|:------------|