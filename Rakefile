#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# Fix 'no method error 'last_comment'
module FixRakeLastComment
  def last_comment
    last_description
  end
end
Rake::Application.send :include, FixRakeLastComment
# Fix end

Secondhand::Application.load_tasks
