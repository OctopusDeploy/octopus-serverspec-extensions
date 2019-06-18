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
require 'octopus_serverspec_extensions/type/octopus_deploy_user.rb'
require 'octopus_serverspec_extensions/type/windows_dsc.rb'
require 'octopus_serverspec_extensions/type/windows_firewall.rb'
require 'octopus_serverspec_extensions/type/windows_scheduled_task.rb'
require 'octopus_serverspec_extensions/matcher/have_version.rb'
require 'octopus_serverspec_extensions/matcher/run_under_account.rb'
require 'octopus_serverspec_extensions/matcher/have_windows_line_endings.rb'
require 'octopus_serverspec_extensions/matcher/have_linux_line_endings.rb'
require 'octopus_serverspec_extensions/version.rb'

# shared
def get_env_var(name)
  raise 'non-approved env var' if name != 'OCTOPUS_CLI_API_KEY' && name != 'OCTOPUS_CLI_SERVER'
  raise 'env var not found' if ENV[name].nil?
  ENV[name]
end