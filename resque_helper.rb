#resque_helper
require 'dotenv'
require 'active_support/core_ext'
require 'sinatra/activerecord'
require 'httparty'
require_relative 'models/model'
require 'pry'

Dotenv.load

module ResqueHelper
  def get_new_subs_properties(product_id, my_sub_id)
    # Get subscription and raw_line_item_properties
    my_local_sub = SubscriptionsUpdated.find_by_subscription_id(my_sub_id)
    my_line_items = my_local_sub.raw_line_items
    my_prod = CurrentProduct.find_by_prod_id_value(product_id)
    next_month_product_id = my_prod.next_month_prod_id
    my_new_product_info = UpdateProduct.find_by_shopify_product_id(next_month_product_id)
    # puts my_new_product_info.inspect

    # Now get product_collection property and loop through my_raw_line_items to set or add
    my_product_collection = my_new_product_info.product_collection
    found_collection = false

    my_line_items.map do |mystuff|
      # puts "#{key}, #{value}"
      if mystuff['name'] == 'product_collection'
        mystuff['value'] = my_product_collection
        found_collection = true
      end
    end
    puts "my_line_items = #{my_line_items.inspect}"

    if found_collection == false
      # only if I did not find the product_collection property in the line items do I need to add it
      puts "We are adding the product collection to the line item properties"
      my_line_items << { "name" => "product_collection", "value" => my_product_collection }
    end

    stuff_to_return =
      if my_prod.prepaid?
        { "properties" => my_line_items }
      else
        { "sku" => my_new_product_info.sku, "product_title" => my_new_product_info.product_title, "shopify_product_id" => my_new_product_info.shopify_product_id, "shopify_variant_id" => my_new_product_info.shopify_variant_id, "properties" => my_line_items }
      end

    stuff_to_return
  end

  def update_subscriptions_next_month(params)
    puts params.inspect
    recharge_change_header = params['recharge_change_header']
    Resque.logger = Logger.new("#{Dir.getwd}/logs/update_subs_resque.log")
    Resque.logger.info "For updating subscriptions Got params #{params.inspect}"
    my_now = Time.now

    my_subs = SubscriptionsUpdated.where(updated: false)
    my_subs.each do |sub|
      # Resque.logger.info sub.inspect
      # update stuff here
      my_sub_id = sub.subscription_id
      my_product_id = sub.shopify_product_id
      puts "#{my_sub_id}, #{my_product_id}"
      puts sub.inspect
      Resque.logger.info "#{my_sub_id}, #{my_product_id}"
      Resque.logger.info sub.inspect
      new_prod_info = get_new_subs_properties(my_product_id, my_sub_id)
      puts "NEW PRODUCT INFO: #{new_prod_info}"
      Resque.logger.info "new prod info = #{new_prod_info}"
      body = new_prod_info.to_json

      my_update_sub = HTTParty.put("https://api.rechargeapps.com/subscriptions/#{my_sub_id}", :headers => recharge_change_header, :body => body, :timeout => 80)
      puts my_update_sub.inspect
      Resque.logger.info my_update_sub.inspect

      if my_update_sub.code == 200
        # set update flag and print success
        sub.updated = true
        time_updated = DateTime.now
        time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
        sub.processed_at = time_updated_str
        sub.save
        puts "Updated subscription id #{my_sub_id}"
        Resque.logger.info "Updated subscription id #{my_sub_id}"
      else
        # echo out error message.
        puts "WARNING -- COULD NOT UPDATE subscription #{my_sub_id}"
        Resque.logger.warn "WARNING -- COULD NOT UPDATE subscription #{my_sub_id}"
      end

      Resque.logger.info "Sleeping 6 seconds"
      sleep 6
      my_current = Time.now
      duration = (my_current - my_now).ceil
      Resque.logger.info "Been running #{duration} seconds"

      if duration > 480
        Resque.logger.info "Been running more than 8 minutes must exit"
        break
      end
    end
    puts "All done updating subscriptions!"
    Resque.logger.info "All done updating subscriptions!"
  end

  def bad_monthly_box(params)
      puts params.inspect
      recharge_change_header = params['recharge_change_header']
      #my_new_product_info = UpdateProduct.find_by_shopify_product_id('91235975186')
      #above is Fit & Fierce - 5 Item
      #91236171794
      my_new_product_info = UpdateProduct.find_by_shopify_product_id('91236171794')
      #above is Fit & Fierce - 3 Item

      stuff_to_return = {"sku" => my_new_product_info.sku, "product_title" => my_new_product_info.product_title, "shopify_product_id" => my_new_product_info.shopify_product_id, "shopify_variant_id" => my_new_product_info.shopify_variant_id}


      my_subs = BadMonthlyBox.where("updated = ?", false)
      my_subs.each do |sub|
          puts sub.inspect
          my_sub_id = sub.subscription_id
          body = stuff_to_return.to_json

          my_update_sub = HTTParty.put("https://api.rechargeapps.com/subscriptions/#{my_sub_id}", :headers => recharge_change_header, :body => body, :timeout => 80)
          puts my_update_sub.inspect
          if my_update_sub.code == 200
              sub.updated = true;
              time_updated = DateTime.now
              time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
              sub.updated_at = time_updated_str
              sub.save

          else
              puts "could not update subscription!"
          end

          sleep 6

      end

      # puts stuff_to_return
  end
end
