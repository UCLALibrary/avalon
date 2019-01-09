# frozen_string_literal: true
# config valid for current version and patch releases of Capistrano
lock '>=3.6.1'

set :application, 'avalon'
set :repo_url, 'https://github.com/UCLALibrary/avalon.git'

set :deploy_to, '/opt/avalon'
set :rails_env, 'production'

if ENV['VIA_JUMP'] == "yes"
  require 'net/ssh/proxy/command'

  # Define the hostanme of the server to tunnel through
  jump_host = ENV['JUMP_HOST'] || 'jump.library.ucla.edu'

  # Define the port number of the jump host
  jump_port = ENV['JUMP_PORT'] || '31926'

  # Define the username for tunneling
  jump_user = ENV['JUMP_USER'] || ENV['USER']

  # Configure Capistrano to use the jump host as a proxy
  ssh_command = "ssh -p #{jump_port} #{jump_user}@#{jump_host} -W %h:%p"
  set :ssh_options, proxy: Net::SSH::Proxy::Command.new(ssh_command)
end

set :log_level, :debug
set :bundle_flags, '--deployment --with mysql'

set :default_env, 'PASSENGER_INSTANCE_REGISTRY_DIR' => '/var/run'

set :keep_releases, 5
set :assets_prefix, "#{shared_path}/public/assets"

SSHKit.config.command_map[:rake] = 'bundle exec rake'

set :branch, ENV['REVISION'] || ENV['BRANCH'] || ENV['BRANCH_NAME'] || 'master'

#append :linked_files, "Gemfile.local", "config/*.yml", "config/*/*.yml", "config/initializers/*.rb", "public/robots.txt"
#append :linked_dirs, 'log', 'tmp'

append :linked_dirs, "log"
append :linked_dirs, "public/assets"
append :linked_dirs, "tmp/pids"
append :linked_dirs, "tmp/cache"
append :linked_dirs, "tmp/sockets"
append :linked_files, ".env.production"
append :linked_files, "config/secrets.yml"

set :conditionally_migrate, true
set :keep_assets, 2
set :migration_role, :app
set :migration_servers, -> { primary(fetch(:migration_role)) }
set :passenger_restart_with_touch, true
set :resque_environment_task, true

after "deploy:restart", "resque:restart"
after "deploy:restart", "resque:scheduler:restart"

# Capistrano passenger restart isn't working consistently,
# so restart apache2 after a successful deploy, to ensure
# changes are picked up.
namespace :deploy do
  after :finishing, :restart_apache do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, :httpd
    end
  end
end
