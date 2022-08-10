#scrub_subs_mix_match.rb
require 'dotenv'
require 'active_support/core_ext'
require 'sinatra/activerecord'
require 'httparty'
require_relative 'models/model'
require_relative 'lib/order_size'
require_relative 'lib/clean_mix_match'
#require 'pry'

Dotenv.load

module ScrubSubsMixMatch

  def determine_limits(recharge_header, limit)
    puts "recharge_header = #{recharge_header}"
    my_numbers = recharge_header.split("/")
    my_numerator = my_numbers[0].to_f
    my_denominator = my_numbers[1].to_f
    my_limits = (my_numerator/ my_denominator)
    puts "We are using #{my_limits} % of our API calls"
    if my_limits > limit
        puts "Sleeping 15 seconds"
        sleep 15
    else
        puts "not sleeping at all"
    end

  end

  def recharge_header
        recharge_regular = ENV['RECHARGE_ACCESS_TOKEN']
        
        
        my_change_header = {
          "X-Recharge-Access-Token" => recharge_regular,
          "Accept" => "application/json",
          "Content-Type" =>"application/json"
        }
    return my_change_header
   end

  def scrub_subs_mix_match_properties(params)
    puts "In module, received params #{params.inspect}"
    my_change_header = recharge_header
    puts "my_change_header = #{my_change_header.inspect}"

    subs_to_clean = SubscriptionsUpdated.where("updated = ?", false)

    subs_to_clean.each do |mysub|
        temp_props = mysub.raw_line_items
        temp_props = CleanMixMatch.cleanup_mix_match_props(temp_props)
        puts "Now temp_props = #{temp_props.inspect}"

        temp_props = OrderSize.add_missing_sub_size(temp_props)

        puts "After updating sizes we have have #{temp_props}"

        puts mysub.inspect
        my_prod = CurrentProduct.find_by_prod_id_value(mysub.shopify_product_id)

        is_prepaid_sub = my_prod.prepaid

        next_month_product_id = my_prod.next_month_prod_id
        puts "next_month_product_id = #{next_month_product_id}"
        my_new_product_info = UpdateProduct.find_by_shopify_product_id(next_month_product_id)
        puts my_new_product_info.inspect

        found_unique_id = false
        my_unique_id = SecureRandom.uuid
        found_collection = false

        my_product_collection = my_new_product_info.product_collection

        temp_props.map do |mystuff|
            if mystuff['name'] == 'product_collection'
                mystuff['value'] = my_product_collection
                found_collection = true
            end
            if mystuff['name'] == 'unique_identifier'
                mystuff['value'] = my_unique_id
                found_unique_id = true
            end
        end

        if found_unique_id == false
            puts "We are adding the unique_identifier to the line item properties"
            temp_props << { "name" => "unique_identifier", "value" => my_unique_id }
      
        end

        if found_collection == false
            # only if I did not find the product_collection property in the line items do I need to add it
            puts "We are adding the product collection to the line item properties"
            temp_props << { "name" => "product_collection", "value" => my_product_collection }
        end

        puts "At here"

        if is_prepaid_sub
            recharge_json = {"properties" => temp_props}
        else
            recharge_json = { "sku" => my_new_product_info.sku, "product_title" => my_new_product_info.product_title, "shopify_product_id" => my_new_product_info.shopify_product_id, "shopify_variant_id" => my_new_product_info.shopify_variant_id, "properties" => temp_props }
        end
    
        puts "Sending to Recharge:"
        puts "=================================="
        puts recharge_json.inspect
        puts "----------------------------------"
        

        my_update_sub = HTTParty.put("https://api.rechargeapps.com/subscriptions/#{mysub.subscription_id}", :headers => my_change_header, :body => recharge_json.to_json, :timeout => 80)

        recharge_header = my_update_sub.response["x-recharge-limit"]
        determine_limits(recharge_header, 0.65)

        if my_update_sub.code == 200
          mysub.updated = true
          time_updated = DateTime.now
          time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
          mysub.processed_at = time_updated_str
          mysub.save!
          puts "Updated subscription_id #{mysub.subscription_id}"

        else
            puts "WARNING -- COULD NOT UPDATE subscription_id #{mysub.subscription_id}"
        end

    end

   

    puts "All done scrubbing Mix and Match!"
  end

  

end