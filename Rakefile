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
    FixSubInfo::SubUpdater.new.get_current_products
end

#load Laura Rhaney Fierce_Floral changes
desc 'load Laura Rhaney Fierce_Floral subs to be changed'
task :fierce_floral do |t|
    FixSubInfo::SubUpdater.new.load_fierce_floral
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

#update bad sub
desc 'update bad subscription'
task :update_bad_subs do |t|
    FixSubInfo::SubUpdater.new.update_bad_subs
end

#load threemonths
desc 'load fix_three_months table'
task :load_three_months do |t|
    FixSubInfo::SubUpdater.new.fix_three_months
end

#update_fix_three_months
desc 'update the fix_three_months records in ReCharge'
task :update_fix_three_months do |t|
    FixSubInfo::SubUpdater.new.update_fix_three_months
end 

#load_fix_bad_recurring
desc 'load the bad_recurring_subs table with data'
task :load_bad_recurring_subs do |t|
    FixSubInfo::SubUpdater.new.load_fix_bad_recurring
end

#update_bad_recurring
desc 'update the bad_recurring_subs in ReCharge'
task :update_bad_recurring_subs do |t|
    FixSubInfo::SubUpdater.new.update_bad_recurring
end

#load_tough_luxe_subs
desc 'load bad tough_luxe subs from csv file'
task :load_tough_luxe_subs do |t|
    FixSubInfo::SubUpdater.new.load_tough_luxe_subs

end

#set_up_tough_luxe_update
desc 'set up tough luxe subs to be updated'
task :setup_tough_luxe_update do |t|
    FixSubInfo::SubUpdater.new.set_up_tough_luxe_update

end

#fix_missing_sports_jacket
desc 'fix missing sports-jacket size in subscriptions'
task :fix_missing_sports_jacket do |t|
    FixSubInfo::SubUpdater.new.fix_missing_sports_jacket
end

#fix_filtered_missing_sports_jacket
desc 'fix FILTERED missing sports-jacket size in subscriptions'
task :fix_filtered_missing_sports_jacket do |t|
    FixSubInfo::SubUpdater.new.fix_filtered_missing_sports_jacket
end

end
