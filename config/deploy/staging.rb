require 'bundler/capistrano'
set :git_user, 'sugaryourcoffee'
set :user, 'pierre'
set :domain, 'secondhand.uranus'
set :application, "secondhand"
set :repository,  "git@github.com:#{git_user}/#{application}.git"
set :deploy_to, "/var/www/#{application}"

require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3'
set :rvm_type, :user

role :web, domain                   # Your HTTP server, Apache/etc
role :app, domain                   # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

set :ssh_options, :forward_agent => true
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false
set :rails_env, :staging

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do 
    run "touch #{current_path}/tmp/restart.txt"
  end
end

after 'deploy:create_symlink', 'copy_database_yml'
desc "copy shared/database.yml to current/config/database.yml"
task :copy_database_yml do
  run "cp #{shared_path}/database.yml #{current_path}/config/database.yml"
end
