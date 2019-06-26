# octopus_deploy_tentacle

Describes an Octopus Deploy [Tentacle agent](https://octopus.com/docs/infrastructure/deployment-targets/windows-targets) resource

## Example

```ruby
describe octopus_tentacle('MyTentacle') do
  it { should be_polling_tentacle }
  it { should have_policy('My tentacle policy')}
end
```

#### Type

```ruby
octopus_deploy_tentacle()
```

#### Matchers

| Matcher | Description |
|:--------|:------------|