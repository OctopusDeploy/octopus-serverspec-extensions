# octopus_deploy_account

Describes an [Octopus Infrastructure Account](https://octopus.com/docs/infrastructure/accounts).

A number of properties of Accounts (such as passwords & secret keys) are [sensitive]() values, therefore we can't directly test them. 

## Example

```ruby

describe octopus_deploy_account("myawsaccount").in_space("Octopus") do
    it { should exist }
    it { should be_aws_account }
    it { should_not be_azure_account }
    it { should have_description('My main AWS account') }
end

```

#### Type

```ruby
octopus_deploy_account([server_url, api_key], account_name)
octopus_account([server_url, api_key], account_name)
```

#### Matchers

| Matcher | Description |
|:--------|:------------|
| should exist | Tests if an account of the name exists |
| should be_aws_account | Amazon Web Services account |
| should be_azure_account | Microsoft Azure account   |
| should be_ssh_key_pair | SSH keypair |
| should be_token | A token for use with services such as Kubernetes| 
| should be_username_password | A username and password for use with services supporting user/pass |

