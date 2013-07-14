require 'bundler/capistrano'
set :git_user, 'sugaryourcoffee'
set :user, 'secondhand'
set :domain, 'secondhand.mercury'
set :application, "secondhand"
set :repository,  "git@github.com:#{git_user}/#{application}.git"
set :deploy_to, "/home/#{user}/#{domain}"

require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3'
set :rvm_type, :user

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, domain                   # Your HTTP server, Apache/etc
role :app, domain                   # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false
set :rails_env, :production

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do 
    run "touch #{current_path}/tmp/restart.txt"
  end
  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
  end
end

after 'deploy:create_symlink', 'copy_database_yml'
desc "copy shared/database.yml to current/config/database.yml"
task :copy_database_yml do
  run "cp #{shared_path}/database.yml #{current_path}/config/database.yml"
end
