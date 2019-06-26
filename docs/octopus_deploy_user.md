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
| should exist | Tests for existence of a User account with the given name |
| should be_active | Tests if the user is enabled/has the 'Is Active' checkbox checked | 
| should have_email(email) | Tests the email address associated with the user account |
| should have_api_key(purpose) | Tests if the user has an API Key with the stated purpose field |
| should have_display_name(name) | tests the Display name set for the user |