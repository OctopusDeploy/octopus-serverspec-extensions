# octopus_deploy_user

Describes an Octopus Deploy [User](https://octopus.com/docs/administration/managing-users-and-teams#Managingusersandteams-UserandServiceaccounts) resource

## Example

```ruby
describe octopus_deploy_user('bobthedeveloper') do
  it { should exist }
  it { should be_active }
end
```

#### Type

This type can be instantiated in several ways, depending on [how you authenticate](authentication.md).

```ruby
octopus_deploy_user(url, api_key, user_name)  # url and apikey provided
octopus_deploy_user(user_name)                # using environment vars
octopus_user(url, api_key, user_name)         # shorthand
octopus_user(user_name)
```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| should exist | Tests for existence of a User account with the given name |
| should be_active | Tests if the user is enabled/has the 'Is Active' checkbox checked | 
| should have_email(email) | Tests the email address associated with the user account |
| should have_api_key(purpose) | Tests if the user has an API Key with the stated purpose field |
| should have_display_name(name) | tests the Display name set for the user |