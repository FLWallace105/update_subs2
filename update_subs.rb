#update_subs.rb
require 'dotenv'
Dotenv.load
require 'httparty'
require 'resque'
require 'sinatra'
require 'active_record'
require "sinatra/activerecord"
require_relative 'models/model'
require_relative 'resque_helper'
require 'pry'
require 'shopify_api'

module FixSubInfo
  class SubUpdater
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
      @uri = URI.parse(ENV['DATABASE_URL'])
      @conn = PG.connect(@uri.hostname, @uri.port, nil, nil, @uri.path[1..-1], @uri.user, @uri.password)

      @shopname = ENV['SHOPIFY_SHOP_NAME']
      @api_key = ENV['SHOPIFY_API_KEY']
      @password = ENV['SHOPIFY_API_PASSWORD']

    end

    def get_current_products
      puts "Doing something"
      my_products = CurrentProduct.all
      my_products.each do |product|
        puts product.inspect
      end
    end

    def setup_subscriptions_update_from_prepaid_orders
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      get_subscriptions = "select order_line_items_fixed.subscription_id from update_prepaid, order_line_items_fixed where order_line_items_fixed.order_id = update_prepaid.order_id"
      my_subs = ActiveRecord::Base.connection.exec_query(get_subscriptions)
      my_subs.each do |mys|
        #puts mys.inspect
        subscription_id = mys['subscription_id']
        puts subscription_id
        my_temp_sub = Subscription.find_by_subscription_id(subscription_id)
        next if my_temp_sub.nil?
        SubscriptionsUpdated.create(subscription_id: my_temp_sub.subscription_id, customer_id: my_temp_sub.customer_id, updated_at: my_temp_sub.updated_at, next_charge_scheduled_at: my_temp_sub.next_charge_scheduled_at, product_title: my_temp_sub.product_title, status: my_temp_sub.status, sku: my_temp_sub.sku, shopify_product_id: my_temp_sub.shopify_product_id, shopify_variant_id: my_temp_sub.shopify_variant_id, raw_line_items: my_temp_sub.raw_line_item_properties) 

      end
      puts "Finished setting up parent subs to be updated from child prepaid orders"

    end

    def setup_employee_ghost
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')

      CSV.foreach('employee_customer_ids.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        #puts row.inspect
        customer_id = row['customer_id']
        puts customer_id
        my_subs = Subscription.where("status = ? and customer_id = ? and next_charge_scheduled_at > \'2021-02-28\' ", "ACTIVE", customer_id)
        #puts my_subs.inspect
        my_subs&.each do |mysub|
          puts mysub.inspect
          SubscriptionsUpdated.create(subscription_id: mysub.subscription_id, customer_id: mysub.customer_id, updated_at: mysub.updated_at, next_charge_scheduled_at: mysub.next_charge_scheduled_at, product_title: mysub.product_title, status: mysub.status, sku: mysub.sku, shopify_product_id: mysub.shopify_product_id, shopify_variant_id: mysub.shopify_variant_id, raw_line_items: mysub.raw_line_item_properties) 

        end

      end

    end

    def setup_subscriptions_update_from_csv
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')

      CSV.foreach('nulls_july_9.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        #puts row.inspect
        subscription_id = row['subscription_id']
        puts subscription_id
        my_temp_sub = Subscription.find_by_subscription_id(subscription_id)
        next if my_temp_sub.nil?
        SubscriptionsUpdated.create(subscription_id: my_temp_sub.subscription_id, customer_id: my_temp_sub.customer_id, updated_at: my_temp_sub.updated_at, next_charge_scheduled_at: my_temp_sub.next_charge_scheduled_at, product_title: my_temp_sub.product_title, status: my_temp_sub.status, sku: my_temp_sub.sku, shopify_product_id: my_temp_sub.shopify_product_id, shopify_variant_id: my_temp_sub.shopify_variant_id, raw_line_items: my_temp_sub.raw_line_item_properties) 
      end

    end


    def load_monthly_subs_from_csv
      puts "Starting monthly subs from csv load"
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      matching_subs = 0
      CSV.foreach( 'sept_allocation_bad_outfit.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        #puts row.inspect
        customer_id = row['recharge customer id']
        my_temp_sub = Subscription.find_by_customer_id(customer_id)
        puts my_temp_sub.inspect
        if !my_temp_sub.nil?
          matching_subs += 1
          SubscriptionsUpdated.create(subscription_id: my_temp_sub.subscription_id, customer_id: my_temp_sub.customer_id, updated_at: my_temp_sub.updated_at, next_charge_scheduled_at: my_temp_sub.next_charge_scheduled_at, product_title: my_temp_sub.product_title, status: my_temp_sub.status, sku: my_temp_sub.sku, shopify_product_id: my_temp_sub.shopify_product_id, shopify_variant_id: my_temp_sub.shopify_variant_id, raw_line_items: my_temp_sub.raw_line_item_properties) 
        end

      end
      puts "We have #{matching_subs} subs to update"

    end

    def load_prepaid_subs_ellie_picks
      puts "Starting load of prepaid subs in Ellie Picks"
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      matching_subs = 0
      CSV.foreach( '3month_subs_in_elliepicks.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        #puts row.inspect
        customer_id = row['recharge customer id']
        my_temp_sub = Subscription.find_by_customer_id(customer_id)
        puts my_temp_sub.inspect
        if !my_temp_sub.nil?
          matching_subs += 1
          SubscriptionsUpdated.create(subscription_id: my_temp_sub.subscription_id, customer_id: my_temp_sub.customer_id, updated_at: my_temp_sub.updated_at, next_charge_scheduled_at: my_temp_sub.next_charge_scheduled_at, product_title: my_temp_sub.product_title, status: my_temp_sub.status, sku: my_temp_sub.sku, shopify_product_id: my_temp_sub.shopify_product_id, shopify_variant_id: my_temp_sub.shopify_variant_id, raw_line_items: my_temp_sub.raw_line_item_properties) 
        end

      end
      puts "We have #{matching_subs} subs to update"

    end



    def check_prepaid_subscription_orders
      puts "Starting Check ... "

      CSV.foreach('prepaid_sub_product_collections.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        #puts row.inspect
        my_coll = row['product_collection']
        puts my_coll
        my_sql = "select subscription_id from sub_collection_sizes where product_collection = \'#{my_coll}\' "
        puts my_sql
        temp_response = ActiveRecord::Base.connection.execute(my_sql).values
        #puts temp_response.inspect
        temp_response.each do |myt|
          puts myt
          more_sql = "select orders.order_id, orders.scheduled_at, order_line_items_fixed.title, order_line_items_fixed.product_title from orders, order_line_items_fixed where order_line_items_fixed.order_id = orders.order_id and orders.scheduled_at > '2020-06-30' and orders.scheduled_at < '2020-08-01' and order_line_items_fixed.subscription_id = \'#{myt}\';"
          new_response = ActiveRecord::Base.connection.execute(more_sql).values
          puts new_response.inspect
        end


      end

    end



    def setup_subscription_update_table
      # sets up subscription update tables
      # first delete all records
      #SubscriptionsUpdated.delete_all
      # Now reset index
      #ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      

      

      my_end_month = Date.today.end_of_month
      my_end_month_str = my_end_month.strftime("%Y-%m-%d")

  
      my_end_month = Date.today.end_of_month
      my_end_month_str = my_end_month.strftime("%Y-%m-%d")
      puts "End of the month = #{my_end_month_str}"
      my_start_month_plus = Date.today 
      my_start_month_plus = my_start_month_plus >> 1
      my_start_month_plus = my_start_month_plus.end_of_month + 1
      my_start_month_plus_str = my_start_month_plus.strftime("%Y-%m-%d")
      puts "my start_month_plus_str = #{my_start_month_plus_str}"
      


     

      mar2021_monthly_straggler = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at > '2021-03-05' and subscriptions.next_charge_scheduled_at < '2021-04-01' and sub_collection_sizes.subscription_id = subscriptions.subscription_id and subscriptions.is_prepaid = \'f\' and ( sub_collection_sizes.product_collection not ilike 'ellie%pick%' and sub_collection_sizes.product_collection not ilike 'head%cloud%' and sub_collection_sizes.product_collection not ilike 'viper%vibe%' and sub_collection_sizes.product_collection not ilike 'azure%dream%' and sub_collection_sizes.product_collection not ilike 'on%flip%' and sub_collection_sizes.product_collection not ilike 'precious%peak%' and sub_collection_sizes.product_collection not ilike 'core%strength%' )   "

      jan2021_bill_later_non_prepaid = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at > '2020-12-31' and subscriptions.next_charge_scheduled_at < '2021-02-01' and sub_collection_sizes.subscription_id = subscriptions.subscription_id and subscriptions.is_prepaid = \'f\' and (  sub_collection_sizes.product_collection not ilike 'ellie%pick%' and sub_collection_sizes.product_collection not ilike 'on%run%' and sub_collection_sizes.product_collection not ilike 'coral%kiss%' and sub_collection_sizes.product_collection not ilike 'funfetti%' and sub_collection_sizes.product_collection not ilike 'island%sun%' and sub_collection_sizes.product_collection not ilike 'island%splash%' and sub_collection_sizes.product_collection not ilike 'force%nature%' and sub_collection_sizes.product_collection not ilike 'daily%mantra%' and sub_collection_sizes.product_collection not ilike 'grayscale%')"

      jan2021_nulls_non_prepaid = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at is null and sub_collection_sizes.subscription_id = subscriptions.subscription_id and subscriptions.is_prepaid = \'f\' "

      april2021_nulls_prepaid = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at is null and sub_collection_sizes.subscription_id = subscriptions.subscription_id and ( sub_collection_sizes.product_collection not ilike 'test%collection%'  ) and subscriptions.is_prepaid = \'t\' "

      

      staging_setup_mix_match = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at > '2020-10-19' and subscriptions.next_charge_scheduled_at < '2020-11-01' and sub_collection_sizes.subscription_id = subscriptions.subscription_id and subscriptions.product_title  not ilike \'3%month%\' and  ( sub_collection_sizes.product_collection not ilike 'wild%instinct%' and  sub_collection_sizes.product_collection not ilike 'nightfall%' and sub_collection_sizes.product_collection not ilike 'positively%pink%' and sub_collection_sizes.product_collection not ilike 'namaste%in%' and sub_collection_sizes.product_collection not ilike 'guiding%light%' and sub_collection_sizes.product_collection not ilike 'full%bloom%' and sub_collection_sizes.product_collection not ilike 'what%gem%' and sub_collection_sizes.product_collection not ilike 'ellie%pick%') limit 1000"

      staging_no_floral_bliss = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.is_prepaid = 't'  and sub_collection_sizes.subscription_id = subscriptions.subscription_id and (sub_collection_sizes.product_collection not ilike '%floral%bliss%'  )"

      
      may2021_prepaid_6_31 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at > '2021-05-05' and subscriptions.next_charge_scheduled_at < '2021-06-01' and sub_collection_sizes.subscription_id = subscriptions.subscription_id and   ( sub_collection_sizes.product_collection not ilike 'nine%lives%' and  sub_collection_sizes.product_collection not ilike 'paradiso%' and sub_collection_sizes.product_collection not ilike 'ellie%pick%' ) and subscriptions.is_prepaid = \'t\' "

      #jan2021_monthly = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at > '2020-12-31' and subscriptions.next_charge_scheduled_at < '2021-02-01' and sub_collection_sizes.subscription_id = subscriptions.subscription_id and   ( subscriptions.product_title not ilike 'on%run%' and  subscriptions.product_title not ilike 'coral%kiss%' and  subscriptions.product_title not ilike 'funfetti%' and  subscriptions.product_title not ilike 'island%sunrise%' and  subscriptions.product_title not ilike 'island%splash%' and  subscriptions.product_title not ilike 'force%nature%' and  subscriptions.product_title not ilike 'daily%mantra%' and  subscriptions.product_title not ilike 'grayscale%' and subscriptions.product_title not ilike 'ellie%picks%') and subscriptions.is_prepaid = \'f\' "



     #3 Months - 5 Items


     # first delete all records
     SubscriptionsUpdated.delete_all
     #Now reset index
     ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
     ActiveRecord::Base.connection.execute(may2021_prepaid_6_31)
     
     puts "All done with  set up"


     

    
    end


    def setup_emergence_ellie_picks

      File.delete('missing_sub.csv') if File.exist?('missing_sub.csv')
      missing_file = File.open('missing_sub.csv', 'w')
      missing_file.write("email,subscription_id\n")
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      CSV.foreach('ellie_picks_roll_dye.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        puts row.inspect
        subscription_id = row['subscription_id']
        my_sub = Subscription.find_by_subscription_id(subscription_id)
        puts my_sub.inspect
        if my_sub.nil?
          missing_file.write("#{row['Email']}, #{subscription_id}\n")
        else
        SubscriptionsUpdated.create(subscription_id: subscription_id, customer_id: my_sub.customer_id, updated_at: my_sub.updated_at, next_charge_scheduled_at: my_sub.next_charge_scheduled_at, product_title: my_sub.product_title, status: my_sub.status, sku: my_sub.sku, shopify_product_id: my_sub.shopify_product_id, shopify_variant_id: my_sub.shopify_variant_id, raw_line_items: my_sub.raw_line_item_properties)
        end 
      end

      missing_file.close
      #SubscriptionsUpdated.where("product_title = ?", "Ellie Picks - 5 Items").delete_all

    end

    def nulls_prepaid_subs

      File.delete('prepaid_subs_wildlife.csv') if File.exist?('prepaid_subs_wildlife.csv')

      column_header = ["subscription_id", "next_charge_scheduled_at", "product_title", "email", "first_name", "last_name"]
      CSV.open('prepaid_subs_wildlife.csv','a+', :write_headers=> true, :headers => column_header) do |hdr|
            column_header = nil

      CSV.foreach('prepaid_subs_nulls.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        #puts row.inspect
        real_sub_id = row['real_sub_id']
        puts real_sub_id
        my_sub = Subscription.find_by_subscription_id(real_sub_id)
        puts my_sub.inspect
        customer_id = my_sub.customer_id
        my_customer = Customer.find_by_customer_id(customer_id)
        puts my_customer.inspect

        csv_data_out = [real_sub_id, my_sub.next_charge_scheduled_at, my_sub.product_title, my_customer.email, my_customer.first_name, my_customer.last_name ]
        hdr << csv_data_out

      end

      end
      #above CSV part


    end

    def nulls_monthly_subs
      MonthlySubNull.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('monthly_sub_nulls')

      CSV.foreach('monthly_subs_nulls.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        puts row.inspect
        puts row['col3']
        puts row['col5']
        temp_title = row['col3']
        temp_title = temp_title.gsub(/(\".+\:)/, "")
        temp_title = temp_title.gsub(/\"/, "")
        temp_title = temp_title.gsub(/\}/, "")
        temp_title = temp_title.lstrip
        puts temp_title
        temp_str = row['col5'].to_str
        my_product_id = temp_str.scan(/\d+/)
        puts my_product_id.inspect
        temp_product_id = my_product_id.first
        
        
        puts row['subscription_id']
        MonthlySubNull.create(subscription_id: row['subscription_id'], old_product_id: temp_product_id, old_product_title: temp_title )


      end

      MonthlySubNullConfig.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('monthly_sub_nulls_config')

      my_sql = "select count(id), old_product_title, old_product_id from monthly_sub_nulls group by old_product_title, old_product_id order by old_product_title asc"

      ActiveRecord::Base.connection.execute(my_sql).each do |row|
        puts row.inspect
        MonthlySubNullConfig.create(old_product_id: row['old_product_id'], old_product_title: row['old_product_title'])
      end



    end

    def get_shopify_config_sub_nulls
      puts "Starting"

      #Get Shopify info
      shop_url = "https://#{@api_key}:#{@password}@#{@shopname}.myshopify.com/admin"
      puts shop_url
      
      ShopifyAPI::Base.site = shop_url
      ShopifyAPI::Base.api_version = '2020-04'
      ShopifyAPI::Base.timeout = 180

      my_monthly_sub_null_prods = MonthlySubNullConfig.where("prod_info_updated = ?", false)

      my_monthly_sub_null_prods.each do |myprod|
        my_prod_id = myprod.old_product_id
        puts my_prod_id
        my_product_info = ShopifyAPI::Product.find(my_prod_id)
        #puts my_product_info.inspect
        
        puts my_product_info.attributes['variants'].first.inspect
        my_variant_id = my_product_info.attributes['variants'].first.attributes['id']
        my_sku = my_product_info.attributes['variants'].first.attributes['sku']
        puts my_variant_id
        puts my_sku

        mymeta = ShopifyAPI::Metafield.all(params: {resource: 'products', resource_id: my_prod_id, namespace: 'ellie_order_info', fields: 'value'})
        puts mymeta.inspect
        product_collection = mymeta.first.attributes['value']
        puts product_collection

        myprod.old_product_collection = product_collection
        myprod.old_sku = my_sku
        myprod.old_variant_id = my_variant_id
        myprod.prod_info_updated = true
        myprod.save!

        sleep 3

      end


    end

    def setup_subs_update_monthly_nulls
      #mysql = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties "
      puts "Starting"

      SubscriptionsUpdated.delete_all
      #Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')

      my_subs = MonthlySubNull.all

      my_subs.each do |mys|
        puts mys.inspect
        my_sub_id = mys.subscription_id
        temp_subscription = Subscription.find_by_subscription_id(my_sub_id)
        puts temp_subscription.inspect
        SubscriptionsUpdated.create(subscription_id: temp_subscription.subscription_id, customer_id: temp_subscription.customer_id, updated_at: temp_subscription.updated_at, created_at: temp_subscription.updated_at,  next_charge_scheduled_at: temp_subscription.next_charge_scheduled_at, product_title: temp_subscription.product_title, status: temp_subscription.status, sku: temp_subscription.sku, shopify_product_id: temp_subscription.shopify_product_id, shopify_variant_id: temp_subscription.shopify_variant_id, raw_line_items: temp_subscription.raw_line_item_properties)
        

      end





    end



    def fix_bad_two_months_march
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      CSV.foreach('more_bad_2item_subs_march.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        #puts row.inspect
        my_sub_id = row['subscription id']
        puts my_sub_id
        my_local_sub = Subscription.find_by_subscription_id(my_sub_id)
        puts my_local_sub.inspect

        #insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items

        new_sub_updated = SubscriptionsUpdated.create(subscription_id: my_local_sub.subscription_id, customer_id: my_local_sub.customer_id, updated_at: my_local_sub.updated_at,next_charge_scheduled_at:  my_local_sub.next_charge_scheduled_at, product_title: my_local_sub.product_title, status: my_local_sub.status, sku: my_local_sub.sku, shopify_product_id: my_local_sub.shopify_product_id, shopify_variant_id: my_local_sub.shopify_variant_id, raw_line_items: my_local_sub.raw_line_item_properties  )

      end
      


    end

    def load_fierce_floral
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')

      CSV.foreach('LAURA_GOOD_fierce_floral.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        #puts row.inspect
        my_subscription_id = row['subscription id']
        puts my_subscription_id
        my_local_sub = Subscription.find_by_subscription_id(my_subscription_id)
        puts my_local_sub.inspect

        #insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items

        new_sub_updated = SubscriptionsUpdated.create(subscription_id: my_local_sub.subscription_id, customer_id: my_local_sub.customer_id, updated_at: my_local_sub.updated_at,next_charge_scheduled_at:  my_local_sub.next_charge_scheduled_at, product_title: my_local_sub.product_title, status: my_local_sub.status, sku: my_local_sub.sku, shopify_product_id: my_local_sub.shopify_product_id, shopify_variant_id: my_local_sub.shopify_variant_id, raw_line_items: my_local_sub.raw_line_item_properties  )

      end

    end

    def load_feels_like_summer
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      CSV.foreach('short_customers.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        puts row.inspect
        my_subscription_id = row['subscription_id']
        puts my_subscription_id
        my_local_sub = Subscription.find_by_subscription_id(my_subscription_id)
        puts my_local_sub.inspect
        new_sub_updated = SubscriptionsUpdated.create(subscription_id: my_local_sub.subscription_id, customer_id: my_local_sub.customer_id, updated_at: my_local_sub.updated_at,next_charge_scheduled_at:  my_local_sub.next_charge_scheduled_at, product_title: my_local_sub.product_title, status: my_local_sub.status, sku: my_local_sub.sku, shopify_product_id: my_local_sub.shopify_product_id, shopify_variant_id: my_local_sub.shopify_variant_id, raw_line_items: my_local_sub.raw_line_item_properties  )

      end

      CSV.foreach('short_customers_july_11.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        #puts row.inspect
        if SubscriptionsUpdated.find_by_subscription_id(row['subscription_id'])
          puts "already exists, skipping: #{row['email']}"
          
      else
          puts "New customer to add to subscriptions_updated table: #{row.inspect}"
          my_local_sub = Subscription.find_by_subscription_id(row['subscription_id'])
          temp_updated = SubscriptionsUpdated.create(subscription_id: my_local_sub.subscription_id, customer_id: my_local_sub.customer_id, updated_at: my_local_sub.updated_at,next_charge_scheduled_at:  my_local_sub.next_charge_scheduled_at, product_title: my_local_sub.product_title, status: my_local_sub.status, sku: my_local_sub.sku, shopify_product_id: my_local_sub.shopify_product_id, shopify_variant_id: my_local_sub.shopify_variant_id, raw_line_items: my_local_sub.raw_line_item_properties)
          
      end

      end



    end


    def load_bad_gloves
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      bad_gloves = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_line_items where subscriptions.status = 'ACTIVE' and sub_line_items.name = 'gloves' and sub_line_items.value = '' and subscriptions.subscription_id = sub_line_items.subscription_id"
      ActiveRecord::Base.connection.execute(bad_gloves)

    end

    def back_figure_inventory
      #
      back_basics_tops = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      back_basics_leggings = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      back_basics_bras = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}

      dream_tops = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      dream_leggings = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      dream_bras = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}

      k_tops = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      k_leggings = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      k_bras = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}

      v_tops = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      v_leggings = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      v_bras = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}

      glow_tops = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      glow_leggings = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      glow_bras = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}

      matcha_tops = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      matcha_leggings = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}
      matcha_bras = {"XS" => 0, "S" => 0, "M" => 0, "L" => 0, "XL" => 0}

      #CSV.foreach('april_subs_updated.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        #puts row.inspect
      mysub = SubscriptionsUpdated.all.each do |mysub|
        #subscription_id = row['subscription_id']
        #product_title = row['product_title']
        subscription_id = mysub.subscription_id
        product_title = mysub.product_title
        if (product_title =~ /back\s/i) || (product_title =~ /dream\s/i) || (product_title =~ /kaleidoscope\s/i) || (product_title =~ /violet\s/i) || (product_title =~ /glow\s/i) || (product_title =~ /matcha\s/i)
          puts "#{subscription_id}, #{product_title}"
          my_collection_info = SubCollectionSizes.find_by_subscription_id(subscription_id)
          puts my_collection_info.inspect
          case my_collection_info.product_collection
          when /back\s/i
            back_basics_tops[my_collection_info.tops] = back_basics_tops[my_collection_info.tops] += 1
            back_basics_leggings[my_collection_info.leggings] = back_basics_leggings[my_collection_info.leggings] += 1
            back_basics_bras[my_collection_info.sports_bra] = back_basics_bras[my_collection_info.sports_bra] += 1

          when /dream\s/i
            dream_tops[my_collection_info.tops] = dream_tops[my_collection_info.tops] += 1
            dream_leggings[my_collection_info.leggings] = dream_leggings[my_collection_info.leggings] += 1
            dream_bras[my_collection_info.sports_bra] = dream_bras[my_collection_info.sports_bra] += 1

          when /kaleidoscope\s/i
            k_tops[my_collection_info.tops] = k_tops[my_collection_info.tops] += 1
            k_leggings[my_collection_info.leggings] = k_leggings[my_collection_info.leggings] += 1
            k_bras[my_collection_info.sports_bra] = k_bras[my_collection_info.sports_bra] += 1

          when /violet\s/i
            v_tops[my_collection_info.tops] = v_tops[my_collection_info.tops] += 1
            v_leggings[my_collection_info.leggings] = v_leggings[my_collection_info.leggings] += 1
            v_bras[my_collection_info.sports_bra] = v_bras[my_collection_info.sports_bra] += 1

          when /glow\s/i
            glow_tops[my_collection_info.tops] = glow_tops[my_collection_info.tops] += 1
            glow_leggings[my_collection_info.leggings] = glow_leggings[my_collection_info.leggings] += 1
            glow_bras[my_collection_info.sports_bra] = glow_bras[my_collection_info.sports_bra] += 1

          when /matcha\s/i
            matcha_tops[my_collection_info.tops] = matcha_tops[my_collection_info.tops] += 1
            matcha_leggings[my_collection_info.leggings] = matcha_leggings[my_collection_info.leggings] += 1
            matcha_bras[my_collection_info.sports_bra] = matcha_bras[my_collection_info.sports_bra] += 1

          else
            #Do nothing


          end

        end

      end
      puts "Back to Basics"
      puts "tops: #{back_basics_tops.inspect}"
      puts "leggings: #{back_basics_leggings.inspect}"
      puts "bras: #{back_basics_bras.inspect}"
      puts "Dream On"
      puts "tops: #{dream_tops.inspect}"
      puts "leggings: #{dream_leggings.inspect}"
      puts "bras: #{dream_bras.inspect}"
      puts "Kaleidoscope"
      puts "tops: #{k_tops.inspect}"
      puts "leggings: #{k_leggings.inspect}"
      puts "bras: #{k_bras.inspect}"
      puts "Violet Rhapsody"
      puts "tops: #{v_tops.inspect}"
      puts "leggings: #{v_leggings.inspect}"
      puts "bras: #{v_bras.inspect}"
      puts "Glow Getter"
      puts "tops: #{glow_tops.inspect}"
      puts "leggings: #{glow_leggings.inspect}"
      puts "bras: #{glow_bras.inspect}"
      puts "Matcha Cha Cha"
      puts "tops: #{matcha_tops.inspect}"
      puts "leggings: #{matcha_leggings.inspect}"
      puts "bras: #{matcha_bras.inspect}"

    end



    def load_march_subs
      num_nils = 0
      num_non_nils = 0
      line = 0
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      CSV.foreach('more_bad_2item_subs_march.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        puts row.inspect
        line += 1
        sub_id = row['subscription id']
        puts sub_id
        my_local_sub = Subscription.find_by_subscription_id(sub_id)
        puts my_local_sub.inspect
        if my_local_sub.nil?
          num_nils += 1
        else
          num_non_nils += 1
        
        temp_updated = SubscriptionsUpdated.create(subscription_id: my_local_sub.subscription_id, customer_id: my_local_sub.customer_id, updated_at: my_local_sub.updated_at,next_charge_scheduled_at:  my_local_sub.next_charge_scheduled_at, product_title: my_local_sub.product_title, status: my_local_sub.status, sku: my_local_sub.sku, shopify_product_id: my_local_sub.shopify_product_id, shopify_variant_id: my_local_sub.shopify_variant_id, raw_line_items: my_local_sub.raw_line_item_properties)
        end

      end
      puts "We have #{num_nils} nils and #{num_non_nils} non nils and #{line} lines"

    end


    def filter_out_prepaid_already_assigned
      my_prepaid = 0
      my_filtered_out = 0
      mysubs = SubscriptionsUpdated.all
      mysubs.each do |mys|
        if mys.product_title  =~ /month/i
          my_prepaid += 1
          temp_product_collection = mys.raw_line_items.select{|item| item['name'] == 'product_collection' }
          temp_product_collection_str = temp_product_collection.first['value']
          #puts mys.product_title, mys.raw_line_items
          puts "#{mys.product_title}, #{temp_product_collection_str}"
          if (temp_product_collection_str =~ /high\stide/i) || (temp_product_collection_str =~ /beach\sbash/i) || (temp_product_collection_str =~ /simple\slife/i) || (temp_product_collection_str =~ /sangria\ssplash/i) || (temp_product_collection_str =~ /feels\slike/i)
            puts "we don't need to assign this prepaid sub and should delete it from the subscriptions_updated table!"
            my_filtered_out += 1
            local_id = mys.id
            SubscriptionsUpdated.delete(local_id)
          else
            puts "We need to assign this prepaid sub"
          end
        end

      end
      puts "WE have #{my_prepaid} prepaid subs and #{my_filtered_out} subs we won't be updating they are good to go already we only need to update #{my_prepaid - my_filtered_out} prepaid subs"

    end



    def load_update_products
      UpdateProduct.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('update_products')
      # my_delete = "delete from update_products"
      # @conn.exec(my_delete)
      # my_reorder = "ALTER SEQUENCE current_products_id_seq RESTART WITH 1"
      # @conn.exec(my_reorder)
      my_insert = "insert into update_products (sku, product_title, shopify_product_id, shopify_variant_id, product_collection) values ($1, $2, $3, $4, $5)"
      @conn.prepare('statement1', "#{my_insert}")
      CSV.foreach('update_products_ellie_picks.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
         puts row.inspect
        sku = row['sku']
        product_title = row['product_title']
        shopify_product_id = row['shopify_product_id']
        shopify_variant_id = row['shopify_variant_id']
        product_collection = row['product_collection']
        UpdateProduct.create(sku: sku, product_title: product_title, shopify_product_id: shopify_product_id, shopify_variant_id: shopify_variant_id, product_collection: product_collection)

        #@conn.exec_prepared('statement1', [sku, product_title, shopify_product_id, shopify_variant_id, product_collection])
      end
      puts "Done with update_products table!"
      @conn.close
    end

    def load_current_products
      CurrentProduct.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('current_products')
      puts "I am here"

      # my_delete = "delete from current_products"
      # @conn.exec(my_delete)
      # my_reorder = "ALTER SEQUENCE current_products_id_seq RESTART WITH 1"
      # @conn.exec(my_reorder)

      my_config_sql = "select count(id), product_title, shopify_product_id from subscriptions_updated group by product_title, shopify_product_id order by product_title asc"

      ActiveRecord::Base.connection.execute(my_config_sql).each do |row|
        puts row.inspect
        next_month_prod_id = "FAIL"
        my_title = row['product_title']
        my_prod_id = row['shopify_product_id']

        case my_title
        when /\s2\sitem/i
          next_month_prod_id = "4399742615610"
        when /\s3\sitem/i
          next_month_prod_id = "4399742746682"
        when /\s5\sitem/i
          next_month_prod_id = "4399742910522"
        when "3 MONTHS"
          next_month_prod_id = "4399742910522"
        else
          next_month_prod_id = "4399742910522"
        end
        CurrentProduct.create(prod_id_key: my_title, prod_id_value: my_prod_id, next_month_prod_id: next_month_prod_id, prepaid: true )

      end
      my_current_products = CurrentProduct.all
      my_current_products.each do |myp|
        puts myp.inspect
      end

      exit

      my_insert = "insert into current_products (prod_id_key, prod_id_value, next_month_prod_id, prepaid) values ($1, $2, $3, $4)"
      @conn.prepare('statement1', "#{my_insert}")
      CSV.foreach('aug2020_employees_ghost.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
         puts row.inspect
        prod_id_key = row['prod_id_key']
        prod_id_value = row['prod_id_value']
        next_month_prod_id = row['next_month_prod_id']
        prepaid = row['prepaid']
        @conn.exec_prepared('statement1', [prod_id_key, prod_id_value, next_month_prod_id, prepaid])
      end
      @conn.close
    end

    def load_inventory_sizes
      SubsUpdatedInventorySize.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('subs_updated_inventory_sizes')

      CSV.foreach('subs_updated_inventory_sizes.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        puts row.inspect
        SubsUpdatedInventorySize.create(product_type: row['product_type'], product_size: row['product_size'], inventory_avail: row['inventory_avail'], inventory_assigned: row['inventory_assigned'])

      end
      puts "All done"

    end

    def update_subscription_product
      params = {"action" => "updating subscription product info", "recharge_change_header" => @my_change_charge_header}
      Resque.enqueue(UpdateSubscriptionProduct, params)
    end

    class UpdateSubscriptionProduct
      extend ResqueHelper

      @queue = "subscription_property_update"
      def self.perform(params)
        # logger.info "UpdateSubscriptionProduct#perform params: #{params.inspect}"
        update_subscriptions_next_month(params)
      end
    end

    def load_bad_alternate_monthly_box
      BadMonthlyBox.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('bad_monthly_box')
      CSV.foreach('ellie_threepack.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        puts row.inspect
        subscription_id = row['subscription_id']
        bad_monthly = BadMonthlyBox.create(subscription_id: subscription_id)
        BadMonthlyBox.update_all(updated_at: nil)
      end
    end

    def update_bad_alternate_monthly_box
      params = { "action" => "bad_monthly_box", "recharge_change_header" => @my_change_charge_header }
      Resque.enqueue(UpdateBadMonthlyBox, params)
    end

    def update_bad_subs
      params = { "action" => "fix_bad_subs", "recharge_change_header" => @my_change_charge_header }
      Resque.enqueue(FixBadSubInfo, params)

    end

    def update_bad_gloves_subs
      params = { "action" => "update_bad_gloves_subs", "recharge_change_header" => @my_change_charge_header }
      Resque.enqueue(FixBadGloveSub, params)

    end

    class FixBadGloveSub
      extend ResqueHelper
      @queue = "bad_gloves_subs"
      def self.perform(params)
        update_bad_gloves(params)
      end

    end

    class UpdateBadMonthlyBox
      extend ResqueHelper
      @queue = "bad_monthly_box"
      def self.perform(params)
        # logger.info "UpdateSubscriptionProduct#perform params: #{params.inspect}"
        bad_monthly_box(params)
      end
    end

    class FixBadSubInfo
      extend ResqueHelper
      @queue = "fix_bad_sub"
      def self.perform(params)
        fix_bad_sub(params)

      end
    end

    #Code to fix Improperly set up In the Zone, Set the Pace, All Star as recurring instead of
    #one time only.
    def load_improper_setup


    end

    #Code to fix the bad Three Months

    def fix_three_months
      FixThreeMonths.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('fix_three_months')
      my_sql_command = "insert into fix_three_months (subscription_id, customer_id, next_charge_scheduled_at, price, status, product_title, product_id, variant_id, sku, line_item_properties) select subscription_id, customer_id, next_charge_scheduled_at, price,  status, product_title,  shopify_product_id, shopify_variant_id, sku, raw_line_item_properties from subscriptions where status = \'ACTIVE\' and price > 49.95 "

      records_array = ActiveRecord::Base.connection.execute(my_sql_command)

    end

    def update_fix_three_months
      #puts "I am here"
      params = { "recharge_change_header" => @my_change_charge_header }
      #puts params.inspect
      Resque.enqueue(FixThreeMonths, params)
      
    end

    class FixThreeMonths
      extend ResqueHelper
      @queue = "update_three_months_subs"
      
      def self.perform(params)
        puts "Starting job"
        #puts "here params are #{params.inspect}"
        three_months_subs(params)

      end

    end

    def load_fix_bad_recurring
      BadRecurringSub.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('bad_recurring_subs')
      my_sql_command = "insert into bad_recurring_subs (subscription_id, customer_id, next_charge_scheduled_at, price, status, product_title, product_id, variant_id, sku, line_item_properties, expire_after_specific_number_charges) select subscription_id, customer_id, next_charge_scheduled_at, price,  status, product_title,  shopify_product_id, shopify_variant_id, sku, raw_line_item_properties, expire_after_specific_number_charges from subscriptions where status = \'ACTIVE\' and (product_title ilike \'All%Star%march%\' or product_title ilike \'Set%the%Pace%march%\' or product_title ilike \'In%the%zone%march%\')"

      records_array = ActiveRecord::Base.connection.execute(my_sql_command)


    end

    def update_bad_recurring
      #puts "I am here"
      params = { "recharge_change_header" => @my_change_charge_header }
      #puts params.inspect
      Resque.enqueue(FixBadRecurring, params)     
    end

    class FixBadRecurring
      extend ResqueHelper
      @queue = "update_bad_recurring"    
      def self.perform(params)
        puts "Starting job"
        #puts "here params are #{params.inspect}"
        update_bad_recurring(params)
      end
    end

    def fix_missing_sports_jacket
      puts "Starting to fix missing sports-jacket subs ..."
      params = { "recharge_change_header" => @my_change_charge_header }
      Resque.enqueue(FixMissingSportsJacket, params)

    end

    class FixMissingSportsJacket
      extend ResqueHelper
      @queue = "update_missing_sports_jacket"
      def self.perform(params)
        puts "starting to update missing sports-jacket sizes"
        update_missing_sports_jacket(params)
      end
    end

    def fix_filtered_missing_sports_jacket
      puts "Fixing filtered sports-jacket subs"
      params = { "recharge_change_header" => @my_change_charge_header }
      Resque.enqueue(FixFilteredSportsJacket, params)

    end


    class FixFilteredSportsJacket
      extend ResqueHelper
      @queue = "update_filtered_sports_jacket"
      def self.perform(params)
        puts "starting filtered missing sports-jacket list"
        update_missing_sports_jacket_filtered(params)
      end

    end



    #900+ subscribers get Street Smarts2 collection
    def load_tough_luxe_subs
      puts "Starting Tough Luxe Subs import"
      ToughLuxeSub.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('tough_luxe_subs')
      CSV.foreach('tough_luxe_customers.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        puts row.inspect
        email = row['email']
        puts email
        bad_tough_luxe = ToughLuxeSub.create(email: email)
        
      end
      puts "Done"


    end

    def set_up_tough_luxe_update
      # Hard code three months product ids
      three_months = 23729012754
      three_months_auto = 10301516626
      vip_three_month = 9109818066
      vip_three_monthly = 9175678162

      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')


      processed_subs = 0
      prepaid_subs = 0
      mysubs = ToughLuxeSub.all
      mysubs.each do |sub|
        puts sub.inspect
        my_email = sub.email
        my_customer = Customer.find_by_email(my_email)
        if !my_customer.nil?
          sub.found_customer = true
          sub.save!
          processed_subs += 1
          my_customer_id = my_customer.customer_id
          puts my_customer.inspect
          my_subscriptions = Subscription.where("status = ? and customer_id = ?", 'ACTIVE', my_customer_id)
          my_subscriptions.each do |mysub|
          puts mysub.inspect
            local_shopify_product_id = mysub.shopify_product_id
            if local_shopify_product_id == three_months || local_shopify_product_id == three_months_auto ||  local_shopify_product_id == vip_three_month || local_shopify_product_id == vip_three_monthly
              puts "funky"
              #processed_subs -= 1
              prepaid_subs += 1
            else
              puts "non funky"
              #Add to subscriptions_updated here
              #insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties
              new_sub_updated = SubscriptionsUpdated.create(subscription_id: mysub.subscription_id, customer_id: mysub.customer_id, updated_at: mysub.updated_at, next_charge_scheduled_at: mysub.next_charge_scheduled_at, product_title: mysub.product_title, status: mysub.status, shopify_product_id: mysub.shopify_product_id, shopify_variant_id: mysub.shopify_variant_id, raw_line_items: mysub.raw_line_item_properties)


            end
          end
        else
          puts "Can't find this customer anymore!"

        end
        
        puts "--------"

      end
      puts "Processed #{processed_subs} subs and did not process #{prepaid_subs} prepaid subs"

    end




    private

    def not_canceled_orders_from_boxes(monthly_box1, monthly_box2, monthly_box3)
      Order.where(
        "status NOT ILIKE ?", 'CANCELLED'
      ).where("scheduled_at > ?", DateTime.now).select do |order|
        [monthly_box1, monthly_box2, monthly_box3].include?(order.shopify_product_id)
      end
    end
  end
end
