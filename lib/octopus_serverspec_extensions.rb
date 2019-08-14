require 'octopus_serverspec_extensions/type/chocolatey_package.rb'
require 'octopus_serverspec_extensions/type/npm_package.rb'
require 'octopus_serverspec_extensions/type/java_property_file.rb'
require 'octopus_serverspec_extensions/type/octopus_deploy_tentacle.rb'
require 'octopus_serverspec_extensions/type/octopus_deploy_worker.rb'
require 'octopus_serverspec_extensions/type/octopus_deploy_environment.rb'
require 'octopus_serverspec_extensions/type/octopus_deploy_project_group.rb'
require 'octopus_serverspec_extensions/type/octopus_deploy_worker_pool.rb'
require 'octopus_serverspec_extensions/type/octopus_deploy_account.rb'
require 'octopus_serverspec_extensions/type/octopus_deploy_smtp_config.rb'
require 'octopus_serverspec_extensions/type/octopus_deploy_upgrade_config.rb'
require 'octopus_serverspec_extensions/type/octopus_deploy_user.rb'
require 'octopus_serverspec_extensions/type/octopus_deploy_space.rb'
require 'octopus_serverspec_extensions/type/windows_dsc.rb'
require 'octopus_serverspec_extensions/type/windows_firewall.rb'
require 'octopus_serverspec_extensions/type/windows_scheduled_task.rb'
require 'octopus_serverspec_extensions/matcher/have_version.rb'
require 'octopus_serverspec_extensions/matcher/run_under_account.rb'
require 'octopus_serverspec_extensions/matcher/have_windows_line_endings.rb'
require 'octopus_serverspec_extensions/matcher/have_linux_line_endings.rb'
require 'octopus_serverspec_extensions/version.rb'

private

def get_env_var(name)
  raise 'unexpected env var' if name != 'OCTOPUS_CLI_API_KEY' && name != 'OCTOPUS_CLI_SERVER'
  raise "env var #{name} not found" if ENV[name].nil?
  ENV[name]
end

def get_octopus_url(server_url)
  # returns the url or nil
  if server_url.nil?
    server_url = get_env_var('OCTOPUS_CLI_SERVER')
  end

  server_url
end

def get_octopus_api_key(api_key)
  # returns the api key or nil
  if api_key.nil?
    api_key = get_env_var('OCTOPUS_CLI_API_KEY')
  end

  api_key
end

def get_octopus_creds(args)
  server = args[0]
  api_key = args[1]

  if args.length != 0 && args.length != 2
    raise "Supplied credentials invalid. Expected: [url, api_key] Received: #{args}"
  end

  if server.nil?
    server = get_env_var('OCTOPUS_CLI_SERVER')
  end

  if api_key.nil?
    api_key = get_env_var('OCTOPUS_CLI_API_KEY')
  end

  # are they still nil? raise an error
  if api_key.nil? or server.nil?
    raise "Supplied credentials invalid. One or more of [server, api_key] was null. " +
      "If you intended to use Environment Variables, please check the value of OCTOPUS_CLI_SERVER and OCTOPUS_CLI_API_KEY"
  end

  server = server.chomp("/") # remove the trailing slash if it exists

  [server, api_key]
end

def check_supports_spaces(server_url)
  begin
    resp = Net::HTTP.get_response(URI.parse("#{server_url}/api/"))
    body = JSON.parse(resp.body)
    version = body['Version']
    return Gem::Version.new(version) > Gem::Version.new('2019.0.0')
  rescue => e
    raise "check_supports_spaces: Unable to connect to #{server_url}: #{e}"
  end
end