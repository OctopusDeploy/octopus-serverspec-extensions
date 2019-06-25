# Authenticating to your Octopus Server

There are two ways of authenticating to your Octopus Server when using the Serverspec Extensions

#### 1. Provide creds with each type

Makes sense if you're testing multiple Octopus Servers in the same ruby script. Simply provide the URL and API key of your Octopus server immediately in your type

The following example will connect to a specific server using a specific API key

```ruby
describe octopus_deploy_account('https://my.octopus/', 'API-1234ABCDE5678FGHI', 'myawsaccount').in_space('Octopus') do
    it { should exist }
end
``` 


#### 2. Using Environment variables

If you do not provide a URL and API key in your type call, the type will try to fall back to environment variables. These variables are the same as we use in the [octo.exe command line utility](https://octopus.com/docs/octopus-rest-api/octo.exe-command-line).

This option is much cleaner to read, but can be less explicit if you have multiple Octopus servers


| Variable              | Description                                                                        |
|:----------------------|:-----------------------------------------------------------------------------------|
| OCTOPUS_CLI_SERVER    | The http or https URL of your Octopus Deploy server: e.g. https://my.octopus.app/  |
| OCTOPUS_CLI_API_KEY   | A valid API key, with rights to view the resources you're testing                  |

The following example will attempt to use the Environment variables. If they are not present, it will raise an exception

```ruby
describe octopus_deploy_account('myawsaccount').in_space('Octopus') do
    it { should exist }
end
``` 

#### 3. Hybrid

You can provide the types with a different environment varaible by using Ruby's `ENV[]` hash

```ruby
describe octopus_deploy_smtp_config(ENV['MY_OCTOPUS_URL'], ENV['MY_OCTOPUS_API_KEY']) do
  it { should be_configured }
end
```

