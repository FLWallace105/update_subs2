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
require_relative 'download_subs'
#require 'pry'


namespace :download_subs do 
    desc 'get all active recharge subs'
    task :download_all_subs do |t|
        DownloadSubs::GetSubs.new.get_all_active_subs

    end

    desc 'get all orders'
    task :download_all_orders do |t|
        DownloadSubs::GetSubs.new.get_all_orders

    end


end

namespace :sub_update do
desc 'list current products'
task :current_products do |t|
    FixSubInfo::SubUpdater.new.get_current_products
end

desc 'read in and create list of nulls prepaid subs'
task :read_in_create_list do |t|
    FixSubInfo::SubUpdater.new.nulls_prepaid_subs
end

desc 'read in and create for updating list of nulls monthly subs'
task :read_in_monthly_nulls do |t|
    FixSubInfo::SubUpdater.new.nulls_monthly_subs

end

desc 'get Shopify configuration information'
task :get_shopify_config_sub_nulls do |t|
    FixSubInfo::SubUpdater.new.get_shopify_config_sub_nulls

end

desc 'setup monthly null subs to be updated on Recharge'
task :setup_monthly_sub_nulls_updated do |t|
    FixSubInfo::SubUpdater.new.setup_subs_update_monthly_nulls
end

desc 'send to Recharge monthly null subs old info'
task :send_recharge_monthly_subs_changes do |t|
    FixSubInfo::SubUpdater.new.recharge_update_monthly_nulls

end

desc 'fix sendgrid skip emails csv'
task :fix_sendgrid_skip_csv do |t|
    FixSubInfo::SubUpdater.new.sendgrid_csv
end



desc 'setup employee subs for ghost'
task :setup_employee_ghost do |t|
    FixSubInfo::SubUpdater.new.setup_employee_ghost
end

desc 'Check prepaid subs child orders for product collection'
task :check_prepaid_subs_orders do |t|
    FixSubInfo::SubUpdater.new.check_prepaid_subscription_orders

end

desc 'load montly sep 2020 subs from CSV'
task :load_monthly_sep2020_from_csv do |t|
    FixSubInfo::SubUpdater.new.load_monthly_subs_from_csv
end

desc 'load prepaid subs sep 2020 in ellie picks from CSV'
task :load_prepaid_subs_sep2020_ellie_picks do |t|
    FixSubInfo::SubUpdater.new.load_prepaid_subs_ellie_picks
end

desc 'back figure inventory adjustments'
task :backfigure_inventory do |t|
    FixSubInfo::SubUpdater.new.back_figure_inventory
end

desc 'set up non allocated prepaid july2020'
task :setup_non_allocated_july2020 do |t|
    FixSubInfo::SubUpdater.new.setup_subscriptions_update_from_csv
end


desc 'load inventory sizes for single collection assignment'
task :load_subs_updated_inventory_sizes do |t|
    FixSubInfo::SubUpdater.new.load_inventory_sizes
end

#Load March Subs from Laura
desc 'load March 2020 subs from Laura'
task :load_march2020_subs do |t|
    FixSubInfo::SubUpdater.new.load_march_subs
end

#Load and fix March bad 2 Months subs
desc 'load bad March 202 subs from Laura'
task :load_bad2item_subs do |t|
    FixSubInfo::SubUpdater.new.fix_bad_two_months_march
end

#load Laura Rhaney Fierce_Floral changes
desc 'load Laura Rhaney Fierce_Floral subs to be changed'
task :fierce_floral do |t|
    FixSubInfo::SubUpdater.new.load_fierce_floral
end

#Load July 2019 Feels Like Summer short customers to move to Simple Life
desc 'load Feels Like Summer short csv tables'
task :load_feels_like_summer do |t|
    FixSubInfo::SubUpdater.new.load_feels_like_summer
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

#load bad_gloves
desc 'load bad gloves no sizes'
task :load_bad_gloves do |t|
    FixSubInfo::SubUpdater.new.load_bad_gloves
end

#fix bad_gloves
desc 'fix bad gloves no sizes'
task :fix_bad_gloves do |t|
    FixSubInfo::SubUpdater.new.update_bad_gloves_subs
end

#filter out prepaid already assigned
desc 'filter out prepaid already assigned'
task :filter_out_prepaid do |t|
    FixSubInfo::SubUpdater.new.filter_out_prepaid_already_assigned
end

desc 'SUB SETUP emergency june assignment ellie picks'
task :emergency_june_ellie_picks_sub_setup do |t|
    FixSubInfo::SubUpdater.new.setup_emergence_ellie_picks

end

desc 'Get subscriptions from updated prepaid orders'
task :get_subs_from_updated_prepaid_orders do |t|
    FixSubInfo::SubUpdater.new.setup_subscriptions_update_from_prepaid_orders
end

end
