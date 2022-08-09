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

    def setup_ellie_picks_config
        UpdateProduct.delete_all
        ActiveRecord::Base.connection.reset_pk_sequence!('update_products')

        CSV.foreach('staging_update_products_ellie_picks.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
           puts row.inspect
           sku = row['sku']
           product_title = row['product_title']
           shopify_product_id = row['shopify_product_id']
           shopify_variant_id = row['shopify_variant_id']
           product_collection = row['product_collection']
           UpdateProduct.create(sku: sku, product_title: product_title, shopify_product_id: shopify_product_id, shopify_variant_id: shopify_variant_id, product_collection: product_collection)
   
           
         end
         puts "Done with update_products table!"

        CurrentProduct.delete_all
        ActiveRecord::Base.connection.reset_pk_sequence!('current_products')

        my_config_sql = "select count(id), product_title, shopify_product_id from subscriptions_updated group by product_title, shopify_product_id order by product_title asc"

        ActiveRecord::Base.connection.execute(my_config_sql).each do |row|
            puts row.inspect
            next_month_prod_id = "FAIL"
            my_title = row['product_title']
            my_prod_id = row['shopify_product_id']

            case my_title
                when /\s2\sitem/i
                    next_month_prod_id = "6959754969249"
                when /\s3\sitem/i
                    next_month_prod_id = "6959754870945"
                when /\s5\sitem/i
                    next_month_prod_id = "6959754674337"
                when "3 MONTHS"
                    next_month_prod_id = "6959754674337"
                else
                    next_month_prod_id = "6959754674337"
            end
        CurrentProduct.create(prod_id_key: my_title, prod_id_value: my_prod_id, next_month_prod_id: next_month_prod_id, prepaid: false )

      end
      my_current_products = CurrentProduct.all
      my_current_products.each do |myp|
        puts myp.inspect
      end

      puts "All done with configuration setup for Mix and Match"

    end

    

    def self.perform
        params = {"action" => "scrubbing mix and match"}
        scrub_subs_mix_match_properties(params)

    end


end