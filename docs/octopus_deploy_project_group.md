# octopus_deploy_project_group

Describes an Octopus [Project Group](https://octopus.com/docs/deployment-process/projects#project-group) resource

## Example

```ruby
describe octopus_project_group('Important Projects') do
  it { should have_description('These are my Very Important projects')}
end
```

#### Type

```ruby
octopus_deploy_project_group('my group')
octopus_project_group('my terse group')
octopus_deploy_projectgroup('back compat to 1.5.x')
octopus_project_group('terse')

```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| should exist | Tests for existence of a project group with the given name |
| should have_description(description) | Tests if the Project group has a given description | 