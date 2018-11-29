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
    puts "In this module"
    puts "#{product_id}, #{my_sub_id}"
    my_local_sub = SubscriptionsUpdated.find_by_subscription_id(my_sub_id)
    puts "my_local_sub = #{my_local_sub.inspect}"
    my_line_items = my_local_sub.raw_line_items
    my_prod = CurrentProduct.find_by_prod_id_value(product_id)
    if my_prod.nil?
      stuff_to_return = {"skip" => true}
    end
    
    next_month_product_id = my_prod.next_month_prod_id
    my_new_product_info = UpdateProduct.find_by_shopify_product_id(next_month_product_id)
    # puts my_new_product_info.inspect

    # Now get product_collection property and loop through my_raw_line_items to set or add
    my_product_collection = my_new_product_info.product_collection
    found_collection = false
    found_unique_id = false
    found_sports_jacket = false
    tops_size = ""
    my_unique_id = SecureRandom.uuid


    my_line_items.map do |mystuff|
      # puts "#{key}, #{value}"
      if mystuff['name'] == 'product_collection'
        mystuff['value'] = my_product_collection
        found_collection = true
      end
      if mystuff['name'] == 'unique_identifier'
        mystuff['value'] = my_unique_id
        found_unique_id = true
      end
      if mystuff['name'] == "sports-jacket"
        found_sports_jacket = true
      end
      if mystuff['name'] == "tops"
        tops_size = mystuff['value']
        puts "ATTENTION -- Tops SIZE = #{tops_size}"
      end
    end
    puts "my_line_items = #{my_line_items.inspect}"
    puts "---------"
    puts "tops_size = #{tops_size}"

    if found_unique_id == false
      puts "We are adding the unique_identifier to the line item properties"
      my_line_items << { "name" => "unique_identifier", "value" => my_unique_id }

    end

    if found_sports_jacket == false
      puts "We are adding the sports-bra size for the sports-jacket size"
      my_line_items << { "name" => "sports-jacket", "value" => tops_size}
    end

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
    puts "Got here"
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
      if new_prod_info['skip'] == true
        next
      else
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


      end
      
      

      Resque.logger.info "Sleeping 6 seconds"
      sleep 6
      my_current = Time.now
      duration = (my_current - my_now).ceil
      puts "Been running #{duration} seconds"
      Resque.logger.info "Been running #{duration} seconds"

      if duration > 480
        Resque.logger.info "Been running more than 8 minutes must exit"
        exit
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


  def fix_bad_sub(params)
    puts params.inspect
    puts "Got here"
    my_now = Time.now
    recharge_change_header = params['recharge_change_header']
    puts recharge_change_header
    mysubs = SubscriptionsUpdated.where(updated: false)
    puts "I am here"

    mysubs.each do |sub|
      prod_title =  sub.product_title
      prod_id = sub.shopify_product_id
      prod_id = prod_id.to_i
      variant_id = sub.shopify_variant_id
      variant_id = variant_id.to_i
      sku = sub.sku
      line_items = sub.raw_line_items
      my_sub_id = sub.subscription_id
      p prod_title
      product_update = { "sku" => sku, "product_title" => prod_title, "shopify_product_id" => prod_id, "properties" => line_items, "shopify_variant_id" => variant_id  }
      body = product_update.to_json
      puts product_update

      hard_code = {"sku" => "722457911059", "product_title" => "La Vie En Rose - 3 Item", "shopify_product_id" => "138427301906", "shopify_variant_id" => "1340705931282" }.to_json

      #fix_sub = HTTParty.put("https://api.rechargeapps.com/subscriptions/10260823", :headers => recharge_change_header, :body => hard_code, :timeout => 80 )
      #p fix_sub.inspect
      #p "done hard code test"

      my_update_sub = HTTParty.put("https://api.rechargeapps.com/subscriptions/#{sub.subscription_id}", :headers => recharge_change_header, :body => body, :timeout => 80)
      puts my_update_sub.inspect

      if my_update_sub.code == 200
        # set update flag and print success
        sub.updated = true
        time_updated = DateTime.now
        time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
        #sub.processed_at = time_updated_str
        sub.save
        puts "Updated subscription id #{my_sub_id}"
        
      else
        # echo out error message.
        puts "WARNING -- COULD NOT UPDATE subscription #{my_sub_id}"
        
      end

      
      sleep 6
      my_current = Time.now
      duration = (my_current - my_now).ceil
      puts "Been running #{duration} seconds"
      

      if duration > 480
        puts "Been running more than 8 minutes must exit"
        exit
      end

      

    end


  end

  def three_months_subs(params)
    #puts params.inspect
    #puts "Got here"
    my_now = Time.now
    recharge_change_header = params['recharge_change_header']
    #puts recharge_change_header
    #exit
    my_product_collection = "May Flowers - 5 Items"
    mythreesubs = FixThreeMonths.where(updated: false)

    mythreesubs.each do |sub|
      #puts sub.line_item_properties
      
      found_collection = false

      sub.line_item_properties.map do |mystuff|
      # puts "#{key}, #{value}"
      if mystuff['name'] == 'product_collection'
        mystuff['value'] = my_product_collection
        found_collection = true
      end
      end

      puts "my_line_items = #{sub.line_item_properties.inspect}"

      if found_collection == false
        # only if I did not find the product_collection property in the line items do I need to add it
        puts "We are adding the product collection to the line item properties"
        sub.line_item_properties << { "name" => "product_collection", "value" => my_product_collection }
      end

    stuff_to_send = { "sku" => "722457572908", "product_title" => "3 MONTHS", "shopify_product_id" => 23729012754, "shopify_variant_id" => 177939546130, "properties" => sub.line_item_properties }
    puts stuff_to_send
    stuff_to_send_json = stuff_to_send.to_json
    my_sub_id = sub.subscription_id
    my_update_sub = HTTParty.put("https://api.rechargeapps.com/subscriptions/#{my_sub_id}", :headers => recharge_change_header, :body => stuff_to_send_json, :timeout => 80)
    puts my_update_sub.inspect

    if my_update_sub.code == 200
      sub.updated = true
      time_updated = DateTime.now
      time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
      sub.updated_at = time_updated_str
      sub.save
      puts "Updated subscription id #{sub.subscription_id}"

    else
      puts "Could not update subscription id #{sub.subscription_id}"
    end

    sleep 4
    my_current = Time.now
    duration = (my_current - my_now).ceil
    puts "Been running #{duration} seconds"
     

    if duration > 480
        puts "Been running more than 8 minutes must exit"
        exit
    end

    end
  
  end


  def update_bad_recurring(params)
    recharge_change_header = params['recharge_change_header']
    badsubs = BadRecurringSub.where(updated: false)

    badsubs.each do |mysub|
      puts "Subscription_id: #{mysub.subscription_id} expire: #{mysub.expire_after_specific_number_charges}"
      my_sub_id = mysub.subscription_id
      stuff_to_send_json = {"cancellation_reason" => "Misconfigured Subscription"}.to_json
      my_update_sub = HTTParty.post("https://api.rechargeapps.com/subscriptions/#{my_sub_id}/cancel", :headers => recharge_change_header, :body => stuff_to_send_json, :timeout => 80)
      puts my_update_sub.inspect
      puts my_update_sub.code



      sleep 4
    end

  end

end
