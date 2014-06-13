# -*- encoding : utf-8 -*-
# config/deploy.rb
 
require 'capistrano/ext/multistage'
require "rvm/capistrano"
require 'bundler/capistrano' #Using bundler with Capistrano
require 'cape'
 
set :stages, %w(staging production)
set :default_stage, "production"
 
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:auth_methods] = ["publickey"]
ssh_options[:keys] = ["/Users/harryng/Downloads/kaeli.pem"]

Cape do
  mirror_rake_tasks :dev
end