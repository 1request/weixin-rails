# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Wechat::Application.load_tasks

# rake migrate:account_user
namespace :migrate do
  desc "Migration: account.user_id"
  task :account_user => :environment do
    require "./db/migrate/20140630040945_add_user_id_to_customer.rb"
  end

  desc "Migration: customer.last_message_at"
  task :last_message_at => :environment do
    require "./db/migrate/20140630064100_patch_customer_last_message_at.rb"
  end
end