# octopus_deploy_project_group

Describes an Octopus [Project Group](https://octopus.com/docs/deployment-process/projects#project-group) resource

## Example

```ruby
describe octopus_project_group('Important Projects') do
  it { should have_description('These are my Very Important projects')}
end
```

#### Type

This type can be instantiated in several ways, depending on [how you authenticate](authentication.md).

Note: `*_projectgroup` (v.1.5.x) is deprecated in favour of `*_project_group`, but included for backwards compatibility

```ruby
octopus_deploy project_group(server_url, api_key, 'Example Group')   # url and apikey provided
octopus_deploy_project_group('Example Group')                        # using env vars
octopus_project_group(server_url, api_key, 'Example Group')          # shorthand
octopus_project_group('Example Group')
octopus_deploy_projectgroup('Back Compat')                           # deprecated

```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| should exist | Tests for existence of a project group with the given name |
| should have_description(description) | Tests if the Project group has a given description | 