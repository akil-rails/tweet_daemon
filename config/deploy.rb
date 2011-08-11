# Modified capistrano recipe, based on the standard 'deploy' recipe
# provided by capistrano but without the Rails-specific dependencies

set :stages, %w(staging production)
set :default_stage, "production"
require "capistrano/ext/multistage"

# Set some globals
default_run_options[:pty] = true
set :application, "tweet_daemon"

# Deployment
set :deploy_to, "/disk1/#{application}"
set :user, 'rails'

# Get repo configuration
set :scm, "git"
set :scm_username, 'akil-rails'
set :repository, "git@github.com:#{scm_username}/#{application}.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

# No sudo
set :use_sudo, false

# File list in the config_files setting will be copied from the
# 'deploy_to' directory into config, overwriting files from the repo
# with the same name
set :config_files, %w{database.yml twitter.yml}

# List any work directories here that you need persisted between
# deployments. They are created in 'deploy_to'/shared and symlinked
# into the root directory of the deployment.
set :shared_children, %w{log tmp}

# Record our dependencies
unless File.directory?( "#{DaemonKit.root}/vendor/daemon_kit" )
  depend :remote, :gem, "daemon-kit", ">=#{DaemonKit::VERSION}"
end

# Hook into capistrano's events
before "deploy:update_code", "deploy:check"

# Setup log rotation support with every deploy (safe)
#after 'deploy:symlink', 'deploy:logrotate'

# Create some tasks related to deployment
namespace :deploy do

  desc "Get the current revision of the deployed code"
  task :get_current_version do
    run "cat #{current_path}/REVISION" do |ch, stream, out|
      puts "Current revision: " + out.chomp
    end
  end

  desc "Install log rotation script on server"
  task :logrotate do
    require 'erb'
    upload_path = "#{shared_path}/system/logrotate"
    template = File.read("config/deploy/logrotate.erb")
    file = ERB.new(template).result(binding)
    put file, upload_path, :mode => 0644
    run "if [ -e /etc/logrotate.d ]; then sudo cp #{shared_path}/system/logrotate /etc/logrotate.d/#{name}; fi"
  end

end
