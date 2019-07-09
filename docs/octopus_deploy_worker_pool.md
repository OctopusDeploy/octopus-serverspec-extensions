# octopus_deploy_worker_pool

Describes an Octopus Deploy [Worker Pool](https://octopus.com/docs/infrastructure/workers/worker-pools) resource.

## Example

```ruby
describe octopus_deploy_worker_pool('My Worker Pool').in_space("My Space") do
  it { should exist } 
end
```

#### Type

```ruby
octopus_deploy_worker_pool('My Worker Pool').in_space("My Space")
octopus_worker_pool('Pool in Default Space')
```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| should exist | Tests for existence of a pool with this name |