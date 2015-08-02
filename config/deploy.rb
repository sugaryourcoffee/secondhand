set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, 'secondhand'

task :uname do
  run "uname -a"
end
