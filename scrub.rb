require 'dotenv'
Dotenv.load
require 'httparty'
require 'resque'
require 'sinatra'
require 'active_record'
require "sinatra/activerecord"
require_relative 'models/model'


require_relative 'scrub_subs_mix_match'

class Scrub
    extend ScrubSubsMixMatch
    @queue = "scrub_mix_match"

    def initialize
        Dotenv.load
        recharge_regular = ENV['RECHARGE_ACCESS_TOKEN']
        @sleep_recharge = ENV['RECHARGE_SLEEP_TIME']
        @my_header = {
          "X-Recharge-Access-Token" => recharge_regular
        }
        @my_change_charge_header = {
          "X-Recharge-Access-Token" => recharge_regular,
          "Accept" => "application/json",
          "Content-Type" =>"application/json"
        }
        
  
      end

    def setup_mix_match_subs

        scrub_mix_match_sql = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at > '2022-08-09' and subscriptions.next_charge_scheduled_at < '2022-10-01' and sub_collection_sizes.subscription_id = subscriptions.subscription_id and   ( sub_collection_sizes.product_collection  not ilike 'test%prod%' ) and subscriptions.is_prepaid = \'f\' and subscriptions.is_mix_match  = \'t\' limit 10"

        SubscriptionsUpdated.delete_all
        #Now reset index
        ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
        ActiveRecord::Base.connection.execute(scrub_mix_match_sql)
     
        puts "All done with  set up"

        num_subs = SubscriptionsUpdated.count
        puts "We have #{num_subs} to process for stripping mix and match "


    end

    

    def self.perform
        params = {"action" => "scrubbing mix and match"}
        scrub_subs_mix_match_properties(params)

    end


end