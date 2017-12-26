#resque_helper
require 'dotenv'
require 'active_support/core_ext'
require 'sinatra/activerecord'
require 'httparty'
require_relative 'models/model'

Dotenv.load

module ResqueHelper

    def get_new_subs_properties(product_id)
        puts "Got here"
        puts "product_id = #{product_id}"
        my_prod = CurrentProduct.find_by_prod_id_value(product_id)
        puts "found something"
        puts my_prod.inspect
        next_month_product_id = my_prod.next_month_prod_id
        puts "next_month_product_id = #{next_month_product_id}"
        #OK, above works, need to pick with next_month_product_id the proper properties and return them
        #my_new_sub_props = UpdateProduct.find_by

        my_new_product_info = UpdateProduct.find_by_shopify_product_id(next_month_product_id)
        puts my_new_product_info.inspect

        stuff_to_return = {"sku" => my_new_product_info.sku, "product_title" => my_new_product_info.product_title, "shopify_product_id" => my_new_product_info.shopify_product_id, "shopify_variant_id" => my_new_product_info.shopify_variant_id}

        return stuff_to_return
    end

    

    def update_subscription_product(params)
        puts params.inspect
        recharge_change_header = params['recharge_change_header']


        my_subs = SubscriptionsUpdated.where("updated = ?", false)
        my_subs.each do |sub|
            #Resque.logger.info sub.inspect
            #update stuff here
            my_sub_id = sub.subscription_id
            my_product_id = sub.shopify_product_id
            puts "#{my_sub_id}, #{my_product_id}"
            puts sub.inspect
            new_prod_info = get_new_subs_properties(my_product_id)
            puts "new prod info = #{new_prod_info}"
            body = new_prod_info.to_json

            my_update_sub = HTTParty.put("https://api.rechargeapps.com/subscriptions/#{my_sub_id}", :headers => recharge_change_header, :body => body, :timeout => 80)
            puts my_update_sub.inspect
            sleep 6

            if my_update_sub.code == 200
                #set update flag and print success
                sub.updated = true
                time_updated = DateTime.now
                time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
                sub.processed_at = time_updated_str
                sub.save


                else
                #echo out error message.
                puts "WARNING -- COULD NOT UPDATE subscription #{my_sub_id}"

                end
            
            end
        puts "All done updating subscriptions!"
    end




end