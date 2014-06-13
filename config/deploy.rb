# -*- encoding : utf-8 -*-
# config/deploy.rb
 
require 'capistrano/ext/multistage'
require "rvm/capistrano"
require 'bundler/capistrano' #Using bundler with Capistrano
require 'cape'
 
set :stages, %w(staging production)
set :default_stage, "production"
 
 
Cape do
  mirror_rake_tasks :dev
end