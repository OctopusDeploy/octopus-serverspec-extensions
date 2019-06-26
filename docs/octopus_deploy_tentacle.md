# octopus_deploy_tentacle

Describes an Octopus Deploy [Tentacle agent](https://octopus.com/docs/infrastructure/deployment-targets/windows-targets) resource.

Must be run on the same machine as `tentacle.exe` at present. Cannot remotely test tentacles at the present time.

## Example

```ruby
describe octopus_tentacle('MyTentacle') do
  it { should be_polling_tentacle }
  it { should have_policy('My tentacle policy')}
end
```

#### Type

```ruby
octopus_deploy_tentacle([url, api_key], instance_name)
octopus_tentacle([url, api_key], instance_name)
octopus_tentacle([url, api_key], instance_name).in_space('Octopus')

```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| should exist | Tests if tentacle.exe is present locally |
| should be_registered_with_the_server | Checks if this tentacle instance is present in the target server |
| should be_online | Tests if the tentacle has a status of online. If the machine is in a healthcheck, waits until healthcheck completes |
| should be_in_environment(env_name) | Tests if the tentacle is registered to a given [Environment](octopus_deploy_environment.md) |
| should be_in_space(space_name) | Tests if a tentacle appears in a given space. _deprecated_. | 
| should have_tenant(tenant_name) | Tests if a tentacle is registered to a given tenant |
| should have_tentant_tag(tag_name) | Tests if a tentacle is registered to a given tenant tag |
| should have_policy(policy_name) | Tests if a tentacle has a give policy applied |
| should have_role(role_name) | Tests if a tentacle has a given role applied |
| should have_display_name |  Tests if a tentacle has a given display name |
| should have_tenanted_deployment_participation(mode) | Tests if a tentacle can take part in tenanted deployments |
| should be_polling_tentacle | Tests if a tentacle is in the 'polling' or 'Active' mode |
| should be_listening_tentacle |  Tests if a tentacle is in the 'listening' or 'Passive' mode |