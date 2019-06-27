# octopus_deploy_worker

Describes the state of an [Octopus Deploy Worker](https://octopus.com/docs/infrastructure/workers) Agent resource

A worker is essentially a specialised version of the Tentacle Agent resource, so this Type has much in common.

## Example

```ruby
describe octopus_worker('WorkerInstance').in_space('TeamBlue') do
  it { should exist }
  it { should be_online }
  it { should be_listening_worker }
  it { should have_display_name('Blue Team worker') }
end
```


#### Type

```ruby
octopus_deploy_worker([url, api_key], instance_name)
octopus_worker([url, api_key], instance_name)
octopus_deploy_worker([url, api_key], instance_name).in_space(space_name)

```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| should exist | Tests if tentacle.exe is present locally |
| should be_registered_with_the_server | Checks if this worker instance is present in the target server |
| should be_online | Tests if the worker has a status of 'online'. If the machine is in a healthcheck, waits until healthcheck completes |
| should be_in_space(space_name) | Tests if a worker appears in a given space. _deprecated_. | 
| should have_policy(policy_name) | Tests if a worker has a give policy applied |
| should have_display_name |  Tests if a worker has a given display name |
| should be_polling_worker | Tests if a worker is in the 'polling' or 'Active' mode |
| should be_listening_worker |  Tests if a worker is in the 'listening' or 'Passive' mode |