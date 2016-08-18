set :stages, %w(production staging beta backup)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, 'secondhand'

task :uname do
  run "uname -a"
end
