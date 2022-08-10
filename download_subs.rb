#download_subs.rb
require 'dotenv'
Dotenv.load
require 'httparty'
require 'resque'
#require 'sinatra'
require 'active_record'
require "sinatra/activerecord"
require 'json'
require_relative 'models/model'


module DownloadSubs
    class GetSubs

        def initialize
            recharge_regular = ENV['RECHARGE_ACCESS_TOKEN']
            @my_header = {
                "X-Recharge-Access-Token" => recharge_regular
              }
            @my_change_header = {
                "X-Recharge-Access-Token" => recharge_regular,
                "Accept" => "application/json",
                "Content-Type" =>"application/json"
              }

        end


        def get_all_active_subs
            puts "Getting all active subs"
            Subscription.delete_all
            # Now reset index
            ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions')
            SubCollectionSizes.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('sub_collection_sizes')
            SubLineItem.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('sub_line_items')

            subscriptions = HTTParty.get("https://api.rechargeapps.com/subscriptions/count?status=ACTIVE", :timeout => 80, :headers => @my_header)
            #my_response = JSON.parse(subscriptions)
            my_response = subscriptions
            my_count = my_response['count'].to_i

            start = Time.now    
            page_size = 250
            num_pages = (my_count/page_size.to_f).ceil

            puts "We have #{my_count} subscriptions and #{(my_count/page_size.to_f).ceil} pages to download"
            #puts "Sleeping 3 secs"
            #sleep 3

            

            1.upto(num_pages) do |page|
                mysubs = HTTParty.get("https://api.rechargeapps.com/subscriptions?status=ACTIVE&limit=250&page=#{page}", :timeout => 120, :headers => @my_header)
                #puts mysubs.inspect
                recharge_limit = mysubs.response["x-recharge-limit"]
                puts "Here recharge_limit = #{recharge_limit}"

                sub_array = Array.new
                sub_collection_sizes_array = Array.new
                sub_line_sizes_array = Array.new
                sub_raw_skus_array = Array.new

                local_sub = mysubs['subscriptions']
                local_sub.each do |sub|
                    puts "-------------------"
                    puts sub['id']
                    #puts sub.inspect
                    puts "------------------"

                    temp_mix_array = sub['properties'].select {|property| property['name'] == 'is_mix_and_match_order'} 
                    mix_match_boolean  = false
                    if temp_mix_array != []
                        mix_match_boolean = my_bool_true?(temp_mix_array.first['value'])
                    else
                        mix_match_boolean = false
                    end

                    if mix_match_boolean == false && sub['properties'].select {|property| property['name'] == 'raw_skus'} != []
                        #i.e. there is some raw sku there not scrubbed yet
                        mix_match_boolean = true

                    end

                    temp_raw_skus = sub['properties'].select {|property| property['name'] == 'raw_skus'} 
                    is_raw_sku = false
                    my_raw_skus = ''
                    sku_array = []
                    if temp_raw_skus != []
                        is_raw_sku = true
                        my_raw_skus = temp_raw_skus.first['value']
                        sku_array = my_raw_skus.split(",")
                        sku_array.map! {|x| x.strip}
                    else
                        is_raw_sku = false
                    end
                

                    subscription_id = sub['id']

                    address_id = sub['address_id']
                    customer_id = sub['customer_id']
                    created_at = sub['created_at']
                    updated_at = sub['updated_at']
                    next_charge_scheduled_at = sub['next_charge_scheduled_at']
                    cancelled_at = sub['cancelled_at']
                    product_title = sub['product_title']
                    price = sub['price']
                    quantity = sub['quantity']
                    status = sub['status']
                    shopify_product_id = sub['shopify_product_id']
                    shopify_variant_id = sub['shopify_variant_id']
                    sku = sub['sku']
                    order_interval_unit = sub['order_interval_unit']
                    order_interval_frequency = sub['order_interval_frequency']
                    charge_interval_frequency = sub['charge_interval_frequency']
                    order_day_of_month = sub['order_day_of_month']
                    order_day_of_week = sub['order_day_of_week']
                    raw_properties = sub['properties']
                    properties = sub['properties']
                    expire_after = sub['expire_after_specific_number_charges']
                    is_prepaid = sub['is_prepaid']
                    email = sub['email']
                    is_mix_and_match = mix_match_boolean
                    #create sub
                    #Subscription.create(subscription_id: subscription_id, address_id: address_id, customer_id: customer_id, created_at: created_at, updated_at: updated_at, next_charge_scheduled_at: next_charge_scheduled_at, cancelled_at: cancelled_at, product_title: product_title, price: price, quantity: quantity, status: status, shopify_product_id: shopify_product_id, shopify_variant_id: shopify_variant_id, sku: sku, order_interval_unit: order_interval_unit, order_interval_frequency: order_interval_frequency, charge_interval_frequency: charge_interval_frequency, order_day_of_month: order_day_of_month, order_day_of_week: order_day_of_week, raw_line_item_properties: properties, expire_after_specific_number_charges: expire_after, is_prepaid: is_prepaid, email: email)
                    sub_array << { "subscription_id" => subscription_id, "address_id" => address_id, "customer_id" => customer_id, "created_at" => created_at, "updated_at" => updated_at, "next_charge_scheduled_at" => next_charge_scheduled_at, "cancelled_at" => cancelled_at, "product_title" => product_title, "price" => price, "quantity" =>  quantity, "status" => status, "shopify_product_id" => shopify_product_id, "shopify_variant_id" => shopify_variant_id, "sku" => sku, "order_interval_unit" => order_interval_unit, "order_interval_frequency" => order_interval_frequency, "charge_interval_frequency" => charge_interval_frequency, "order_day_of_month" => order_day_of_month, "order_day_of_week" => order_day_of_week, "raw_line_item_properties" => properties, "expire_after_specific_number_charges" => expire_after, "is_prepaid" => is_prepaid, "email" => email, "is_mix_match" => is_mix_and_match}

                    properties.each do |temp|
                        temp_name = temp['name']
                        temp_value = temp['value']
                        #puts "#{temp_name}, #{temp_value}"
                        if !temp_value.nil? && !temp_name.nil?
                            sub_line_sizes_array << {"subscription_id" => subscription_id, "name" => temp_name, "value" => temp_value}

                        end
                    end

                    if is_raw_sku == true
                        sku_array.each do |mysku|
                            sub_raw_skus_array.push({"subscription_id" => subscription_id, "next_charge_scheduled_at" => next_charge_scheduled_at, "prepaid" => is_prepaid, "sku" => mysku})
                        end
                        #puts "sub_raw_skus_array = #{sub_raw_skus_array.inspect}"
                        
                    end

                    
                    



                    #create sub_collection_sizes

                    my_data = create_properties(raw_properties)

                    product_collection = my_data['product_collection']
                    leggings = my_data['leggings']
                    tops = my_data['tops']
                    sports_bra = my_data['sports_bra']
                    sports_jacket = my_data['sports_jacket']
                    gloves = my_data['gloves']

                    sub_collection_sizes_array << {"subscription_id" => subscription_id, "product_collection" => product_collection, "leggings" => leggings, "sports_bra" => sports_bra, "tops" => tops, "sports_jacket" => sports_jacket, "gloves" => gloves, "prepaid" => is_prepaid, "next_charge_scheduled_at" => next_charge_scheduled_at, "created_at" => created_at, "updated_at" => updated_at}

                    #SubCollectionSizes.create(subscription_id: subscription_id,
                    #    product_collection: product_collection,
                    #    leggings: leggings, tops: tops,
                    #    sports_bra: sports_bra,
                    #    sports_jacket: sports_jacket,
                    #    gloves: gloves, prepaid: is_prepaid, next_charge_scheduled_at: next_charge_scheduled_at)

                    
                end

                sub_array.uniq!
                sub_collection_sizes_array.uniq!

                
                result = Subscription.insert_all(sub_array, unique_by: :subscription_id)
                puts result.inspect
                result2 = SubCollectionSizes.insert_all(sub_collection_sizes_array)
                puts result2.inspect
                result3 = SubLineItem.insert_all(sub_line_sizes_array)

                #puts "sub_raw_skus_array = #{sub_raw_skus_array.inspect}"
                if sub_raw_skus_array != []
                    result4 = SubRawSku.insert_all(sub_raw_skus_array)
                    puts result4.inspect
                end

            puts "Done with page #{page} of #{num_pages} pages"
            determine_limits(recharge_limit, 0.65)
            current = Time.now
            duration = (current - start).ceil
            puts "Been running #{duration} seconds"
            end
            
            puts "All done with subs"

            

        end

        def get_all_orders
            puts "Getting all orders"
            Order.delete_all
            OrderLineItemsFixed.delete_all
            OrderCollectionSize.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('orders')
            ActiveRecord::Base.connection.reset_pk_sequence!('order_line_items_fixed')
            ActiveRecord::Base.connection.reset_pk_sequence!('order_collection_sizes')

            OrderLineItemsVariable.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('order_line_items_variable')

            min_max = get_min_max
            min = min_max['min']
            max = min_max['max']

            order_array = Array.new
            order_collection_sizes_array = Array.new
            order_fixed_line_items_array = Array.new
            order_line_items_variable_array = Array.new

            orders_count = HTTParty.get("https://api.rechargeapps.com/orders/count?scheduled_at_min=\'#{min}\'&scheduled_at_max=\'#{max}\'", :headers => @my_header)
            #my_response = JSON.parse(subscriptions)
            my_response = orders_count
            my_count = my_response['count'].to_i
            puts "We have #{my_count} orders for this month"

            start = Time.now
            page_size = 250
            num_pages = (my_count/page_size.to_f).ceil
            1.upto(num_pages) do |page|
                orders = HTTParty.get("https://api.rechargeapps.com/orders?scheduled_at_min=\'#{min}\'&scheduled_at_max=\'#{max}\'&limit=250&page=#{page}", :headers => @my_header)
                my_orders = orders.parsed_response['orders']
                recharge_limit = orders.response["x-recharge-limit"]
                puts "Here recharge_limit = #{recharge_limit}"

                my_orders.each do |order|

                    #fix mix_match indicator here

                    temp_is_mix_match = false

                    if order['is_prepaid'].to_i == 1
                        order_line_item_info = order['line_items'].first

                        temp_mix_array = order_line_item_info['properties'].select {|property| property['name'] == 'is_mix_and_match_order'} 
                        temp_is_mix_match = false

                        if temp_mix_array != []
                            temp_is_mix_match = my_bool_true?(temp_mix_array.first['value'])
                         else
                            temp_is_mix_match = false
                        end

                        if temp_is_mix_match == false && order_line_item_info['properties'].select {|property| property['name'] == 'raw_skus'} != []
                            #i.e. there is some raw sku there not scrubbed yet
                            temp_is_mix_match = true
    
                        end

                    end

                    




                    puts order.inspect
                    order_id = order['id'] 
                    transaction_id = order['id']
                    charge_status = order['charge_status']
                    payment_processor = order['payment_processor']
                    address_is_active = order['address_is_active'].to_i
                    status = order['status']
                    type = order['type']
                    charge_id = order['charge_id']
                    address_id = order['address_id']
                    shopify_id = order['shopify_id']
                    shopify_order_id = order['shopify_order_id']
                    shopify_order_number = order['shopify_order_number']
                    shopify_cart_token = order['shopify_cart_token']
                    shipping_date = order['shipping_date']
                    scheduled_at = order['scheduled_at']
                    shipped_date = order['shipped_date']
                    processed_at = order['processed_at']
                    customer_id = order['customer_id']
                    first_name = order['first_name']
                    last_name = order['last_name']
                    is_prepaid = order['is_prepaid'].to_i
                    created_at = order['created_at']
                    updated_at = order['updated_at']
                    email = order['email']
                    line_items = order['line_items']
                    raw_line_items = order['line_items'][0]

                    shipping_address = order['shipping_address'].to_json
                    billing_address = order['billing_address'].to_json

                    total_price = order['total_price']

                    order_array << { "order_id" => order_id, "transaction_id" => transaction_id, "charge_status" => charge_status, "payment_processor" => payment_processor, "address_is_active" => address_is_active, "status" => status, "order_type" => type, "charge_id" => charge_id, "address_id" => address_id, "shopify_id" => shopify_id, "shopify_order_id" => shopify_order_id, "shopify_order_number" => shopify_order_number, "shopify_cart_token" => shopify_cart_token, "shipping_date" => shipping_date, "scheduled_at" => scheduled_at, "shipped_date" => shipped_date, "processed_at" => processed_at, "customer_id" => customer_id, "first_name" => first_name, "last_name" => last_name, "is_prepaid" => is_prepaid, "created_at" => created_at, "updated_at" => updated_at, "email" => email, "line_items" => line_items, "total_price" => total_price, "shipping_address" => shipping_address, "billing_address" => billing_address, "is_mix_match" =>  temp_is_mix_match }

                    #puts "order_array = #{order_array.inspect}"
                    #exit

                    


                    if raw_line_items != nil 
    
                        shopify_variant_id = raw_line_items['shopify_variant_id']
                        title = raw_line_items['title']
                        variant_title = raw_line_items['variant_title']
                        subscription_id = raw_line_items['subscription_id']
                        quantity = raw_line_items['quantity'].to_i
                        shopify_product_id = raw_line_items['shopify_product_id']
                        product_title = raw_line_items['product_title']

                        order_fixed_line_items_array << { "order_id" => order_id, "shopify_variant_id" => shopify_variant_id, "title" => title, "variant_title" => variant_title, "subscription_id" => subscription_id, "quantity" => quantity, "shopify_product_id" => shopify_product_id, "product_title" => product_title}

                        my_props = create_order_properties(line_items)

                        order_collection_sizes_array << {"order_id" => order_id, "product_collection" => my_props['product_collection'], "leggings" => my_props['leggings'], "tops" => my_props['tops'], "sports_bra" => my_props['sports_bra'], "sports_jacket" => my_props['sports_jacket'], "gloves" => my_props['gloves'], "prepaid" => is_prepaid, "scheduled_at" => scheduled_at, "created_at" => created_at, "updated_at" => updated_at}

                        #OrderCollectionSize.create(order_id: order_id, product_collection: my_props['product_collection'], leggings: my_props['leggings'], tops: my_props['tops'], sports_bra: my_props['sports_bra'], sports_jacket: my_props['sports_bra'], gloves: my_props['gloves'], prepaid: is_prepaid, scheduled_at: scheduled_at )

                        my_properties = raw_line_items['properties']

                        if my_properties != nil && my_properties != []

                            my_properties.each do |myprop|
                            myname = myprop['name']
                            myvalue = myprop['value']
                            
                            
                            order_line_items_variable_array << {"order_id" => order_id, "name" => myname, "value" => myvalue}

                            end
                        end
                        
        
                        
                    end

            end


            puts "Done with page #{page} of #{num_pages}"
            current = Time.now
            duration = (current - start).ceil
            puts "Been running #{duration} seconds"
            determine_limits(recharge_limit, 0.65)
            end
            puts "All done with orders"
            order_array.uniq!
            Order.upsert_all(order_array, unique_by: :order_id)
            order_fixed_line_items_array.uniq!
            OrderLineItemsFixed.upsert_all(order_fixed_line_items_array, unique_by: :order_id)
            order_collection_sizes_array.uniq!
            OrderCollectionSize.upsert_all(order_collection_sizes_array)
            OrderLineItemsVariable.insert_all(order_line_items_variable_array)


        end


        def create_properties(raw_properties)
            product_collection = raw_properties.select{|x| x['name'] == 'product_collection'}
            if product_collection != []
                if product_collection.first['value'] != [] && !product_collection.first['value'].nil?
                product_collection = product_collection.first['value']
                else
                    product_collection = nil
                end
            else
                product_collection = nil
            end
            leggings = raw_properties.select{|x| x['name'] == 'leggings'}
            if leggings != []
                if leggings.first['value'] != [] && !leggings.first['value'].nil?
                leggings = leggings.first['value'].upcase
                else
                leggings = nil?
                end
            else
                leggings = nil
            end
            tops = raw_properties.select{|x| x['name'] == 'tops'}
            if tops != []
                if tops.first['value'] != [] && !tops.first['value'].nil?
                tops = tops.first['value'].upcase
                else
                tops = nil?
                end
            else
                tops = nil
            end
            sports_bra = raw_properties.select{|x| x['name'] == 'sports-bra'}
            if sports_bra != []
                if sports_bra.first['value'] != [] && !sports_bra.first['value'].nil?
                sports_bra = sports_bra.first['value'].upcase
                else
                sports_bra = nil
                end
            else
                sports_bra = nil
            end
            sports_jacket = raw_properties.select{|x| x['name'] == 'sports-jacket'}
    
            if sports_jacket != []
                if sports_jacket.first['value'] != [] && !sports_jacket.first['value'].nil?
                sports_jacket = sports_jacket.first['value'].upcase
                else
                sports_jacket = nil
                end
            else
                sports_jacket = nil
            end
            gloves = raw_properties.select{|x| x['name'] == 'gloves'}
            if gloves != []
                if gloves.first['value'] != [] && !gloves.first['value'].nil?
                gloves = gloves.first['value'].upcase
                else
                gloves = nil
                end
            else
                gloves = nil
            end
            #puts charge_interval_frequency.inspect
            
            stuff_to_return = {"product_collection" => product_collection, "leggings" => leggings, "tops" => tops, "sports_bra" => sports_bra, "sports_jacket" => sports_jacket, "gloves" => gloves}
            return stuff_to_return
    
        end

        def create_order_properties(my_json)
            #temp_json = JSON.parse(my_json)
            #puts temp_json
            temp_json = my_json
            temp_props = temp_json.first['properties']
            #puts temp_props
    
            product_collection = temp_props.select{|x| x['name'] == 'product_collection'}
            leggings = temp_props.select{|x| x['name'] == 'leggings'}
            tops = temp_props.select{|x| x['name'] == 'tops'}
            sports_bra = temp_props.select{|x| x['name'] == 'sports-bra'}
            sports_jacket = temp_props.select{|x| x['name'] == 'sports-jacket'}
            gloves = temp_props.select{|x| x['name'] == 'gloves'}

            #puts "sports_jacket is #{sports_jacket}"
    
            if product_collection != []
                product_collection = product_collection.first['value']
            else
                product_collection = nil
            end
    
            if leggings != []
                if !leggings.first['value'].nil?
                leggings = leggings.first['value'].upcase
                else
                    leggings = nil
                end 
            else
                leggings = nil
            end
    
            if tops != []
                if !tops.first['value'].nil?
                    tops = tops.first['value'].upcase
                else
                    tops = nil
                end
            else
                tops = nil
            end
    
            if sports_bra != []
                if !sports_bra.first['value'].nil?
                    sports_bra = sports_bra.first['value'].upcase
                else
                    sports_bra = nil
                end
            else
                sports_bra = nil
            end

            if sports_jacket != []
                if !sports_jacket.first['value'].nil?
                    sports_jacket = sports_jacket.first['value'].upcase
                else
                    sports_jacket = nil
                end
            else
                sports_jacket = nil
            end
    
            if gloves != []
                if !gloves.first['value'].nil?
                    gloves = gloves.first['value'].upcase
                else
                    gloves = nil
                end
            else
                gloves = nil
            end
    
            stuff_to_return = {"product_collection" => product_collection, "leggings" => leggings, "tops" => tops, "sports_bra" => sports_bra, "sports_jacket" => sports_jacket, "gloves" => gloves}
            return stuff_to_return
    
    
        end

        def get_active_customers


        end

        def get_active_addresses



        end


        def my_bool_true?(obj)
            obj.to_s.downcase == "true"
        end

        def is_mix_match_sub(line_item)
            mix_match_key = line_item['properties'].select {|property| property['name'] == 'is_mix_and_match_order'}
            mix_match_key.present?  ? (mix_match_key.first['value'].length > 0) : false
        
        end


        def get_min_max
            my_yesterday = Date.today - 3
            my_yesterday_str = my_yesterday.strftime("%Y-%m-%d")
            my_four_months = Date.today >> 2
            my_four_months = my_four_months.end_of_month
            my_four_months_str = my_four_months.strftime("%Y-%m-%d")
            my_hash = Hash.new
            my_hash = {"min" => my_yesterday_str, "max" => my_four_months_str}
            return my_hash

        end

        def determine_limits(recharge_header, limit)
            puts "recharge_header = #{recharge_header}"
            puts "sleeping 1 second"
            sleep 1
            my_numbers = recharge_header.split("/")
            my_numerator = my_numbers[0].to_f
            my_denominator = my_numbers[1].to_f
            my_limits = (my_numerator/ my_denominator)
            puts "We are using #{my_limits} % of our API calls"
            if my_limits > limit
                puts "Sleeping 10 seconds"
                sleep 10
            else
                puts "not sleeping at all"
            end

        end

        


    end
end