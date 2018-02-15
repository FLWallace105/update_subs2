require 'dotenv'
Dotenv.load
require 'redis'
require 'resque'
Resque.redis = Redis.new(url: ENV['REDIS_URL'])
require 'active_record'
#require 'sinatra'
require 'sinatra/activerecord/rake'
require 'resque/tasks'
require_relative 'update_subs'
require 'pry'

namespace :sub_update do
desc 'list current products'
task :current_products do |t|
  binding.pry
    FixSubInfo::SubUpdater.new.get_current_products
end

#setup_subscription_update_table
desc 'set up subscription update table'
task :setup_subs_table do |t|
    FixSubInfo::SubUpdater.new.setup_subscription_update_table
end

#load new products to update subscriptions
desc 'load new products to update subscriptions'
task :load_new_products do |t|
    FixSubInfo::SubUpdater.new.load_update_products
end


#load the current products we need to change
desc 'load the current products we need to update for next month'
task :load_current_products do |t|
    FixSubInfo::SubUpdater.new.load_current_products
end

#update_subscription_product
desc 'update subscriptions with next months product info'
task :update_subs_next_month do |t|
  FixSubInfo::SubUpdater.new.update_subscription_product
end

#load_bad_alternate_monthly_box
desc 'load bad_alternate_monthly_box subscriptions to be fixed'
task :load_bad_alternate_box do |t|
    FixSubInfo::SubUpdater.new.load_bad_alternate_monthly_box
end

#update_bad_alternate_monthly_box
desc 'update bad alternate monthly box'
task :update_bad_alternate_monthly_box do |t|
    FixSubInfo::SubUpdater.new.update_bad_alternate_monthly_box
end

end
