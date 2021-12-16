#resque_helper
require 'dotenv'
require 'active_support/core_ext'
require 'sinatra/activerecord'
require 'httparty'
require_relative 'models/model'
require_relative 'lib/order_size'
#require 'pry'

Dotenv.load

module ResqueHelper

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

  def determine_allocation(my_local_sub)
    puts "Determining allocation"
    #Handling 2 Item stuff
    my_temp_title = my_local_sub.product_title
    
    is_two_item = false

    if my_temp_title =~ /2\sitem/i
      is_two_item = true

    end

    my_line_items = my_local_sub.raw_line_items
    leggings = my_line_items.select{|x| x['name'] == 'leggings'}
    tops = my_line_items.select{|x| x['name'] == 'tops'}
    #sports_jacket = my_line_items.select{|x| x['name'] == 'sports-jacket'}
    sports_bra = ""
    #puts "I am here now"
    if is_two_item == false
      sports_bra = my_line_items.select{|x| x['name'] == 'sports-bra'}
    end
    #fix for missing sports-bra
    #if sports_bra == []
    puts "I am here now"
    #if sports_jacket == []
    #  puts "oops no sports bra/jacket fixing ..."

     # sports_jacket << {"name" => "sports-jacket", "value" => tops.first['value'] }
    #end
    #puts "Now Here"
    if tops == []
      puts "oops no tops fixing ..."

      tops << {"name" => "tops", "value" => leggings.first['value'] }

    end
    puts "Now Here too"

    puts leggings.inspect
    #puts sports_jacket.inspect
    puts is_two_item
    if is_two_item == false
      puts sports_bra.inspect
    end
    puts tops.inspect

    temp_leggings = leggings.first['value']
    #temp_sports_jacket = sports_jacket.first['value']
    temp_tops = tops.first['value']
    if is_two_item == false
      temp_sports_bra = sports_bra.first['value']
      if temp_sports_bra == ""
        temp_sports_bra = temp_tops
      end
    end
    puts "tops then leggings"
    puts temp_leggings
    puts temp_tops
    puts "-------"
    if is_two_item == false
      puts temp_sports_bra
    end

    

    can_proceed = true
    puts "At inventory"

    leggings_avail_inventory = SubsUpdatedInventorySize.where("product_type = ? and product_size = ?", "leggings", temp_leggings).first
    tops_avail_inventory = SubsUpdatedInventorySize.where("product_type = ? and product_size = ?", "tops", temp_tops).first
    #sports_jacket_avail_inventory = SubsUpdatedInventorySize.where("product_type = ? and product_size = ?", "sports-jacket", temp_sports_jacket).first
    if is_two_item == false
      sports_bra_avail_inventory = SubsUpdatedInventorySize.where("product_type = ? and product_size = ?", "sports-bra", temp_sports_bra).first
    end
    puts "Part way through"
    puts leggings_avail_inventory.inventory_avail
    puts tops_avail_inventory.inventory_avail
    #puts sports_jacket_avail_inventory.inventory_avail
    if is_two_item == false
      puts sports_bra_avail_inventory.inventory_avail
    end
    puts "Got here"

    if (leggings_avail_inventory.inventory_avail > 0 && tops_avail_inventory.inventory_avail > 0 &&  is_two_item == false)
      if (sports_bra_avail_inventory.inventory_avail > 0)
      can_proceed = true
      else
        can_proceed = false
      end
      #Do inventory adjustment stuff here?

    elsif (is_two_item == true && leggings_avail_inventory.inventory_avail > 0 && tops_avail_inventory.inventory_avail > 0 )
      can_proceed = true
    else
      can_proceed = false
    end

    puts "Returning to calling method!"
    return can_proceed


  end

  def adjust_inventory(my_local_sub)
    puts "my_local_sub = #{my_local_sub.inspect}"
    #Handling 2 Item stuff
    my_temp_title = my_local_sub.product_title
    
    is_two_item = false

    if my_temp_title =~ /2\sitem/i
      is_two_item = true

    end

    sports_bra = ""
    sports_jacket = ""
    my_line_items = my_local_sub.raw_line_items
    leggings = my_line_items.select{|x| x['name'] == 'leggings'}
    tops = my_line_items.select{|x| x['name'] == 'tops'}
    #sports_jacket = my_line_items.select{|x| x['name'] == 'sports-jacket'}
    if !is_two_item
      sports_bra = my_line_items.select{|x| x['name'] == 'sports-bra'}
    end
    puts leggings.inspect
    puts tops.inspect
    puts sports_bra.inspect
    

    #fix for missing sports-bra
    if sports_bra == []
      puts "oops no sports bra fixing ..."

      sports_bra << {"name" => "sports-bra", "value" => tops.first['value'] }
    end

    if sports_jacket == []
      puts "oops no sports-jacket fixing ..."

      sports_jacket << {"name" => "sports-jacket", "value" => tops.first['value'] }
    end

    if tops == [] 
      puts "oops no tops fixing ..."

      tops << {"name" => "tops", "value" => sports_jacket.first['value'] }
    end

    

    if !is_two_item
      puts sports_bra.inspect

    end

    temp_leggings = leggings.first['value']
    temp_tops = tops.first['value']
    #temp_sports_jacket = sports_jacket.first['value']
    temp_sports_jacket = ""
    if !is_two_item
      temp_sports_bra = sports_bra.first['value']
      if temp_sports_bra == ""
        temp_sports_bra = temp_tops
      end
    end
    puts temp_leggings
    puts temp_tops
    #puts temp_sports_jacket
    puts temp_sports_bra
    if !is_two_item
      puts temp_sports_bra
    end

    
    leggings_avail_inventory = SubsUpdatedInventorySize.where("product_type = ? and product_size = ?", "leggings", temp_leggings).first
    tops_avail_inventory = SubsUpdatedInventorySize.where("product_type = ? and product_size = ?", "tops", temp_tops).first
    #sports_jacket_avail_inventory = SubsUpdatedInventorySize.where("product_type = ? and product_size = ?", "sports-jacket", temp_sports_jacket).first
    if !is_two_item
      sports_bra_avail_inventory = SubsUpdatedInventorySize.where("product_type = ? and product_size = ?", "sports-bra", temp_sports_bra).first
    end

    puts "Before Adjustment:"
    puts "leggings qty: #{leggings_avail_inventory.inventory_avail}"
    puts "tops qty: #{tops_avail_inventory.inventory_avail}"
    #puts "sports-jacket qty: #{sports_jacket_avail_inventory.inventory_avail}"
    if !is_two_item
      puts "bra qty: #{sports_bra_avail_inventory.inventory_avail}"
    end
    puts "======================"
    leggings_avail_inventory.inventory_avail -= 1
    tops_avail_inventory.inventory_avail -= 1
    #sports_jacket_avail_inventory.inventory_avail -= 1
    leggings_avail_inventory.inventory_assigned += 1
    tops_avail_inventory.inventory_assigned += 1
    #sports_jacket_avail_inventory.inventory_assigned += 1

    if !is_two_item
      sports_bra_avail_inventory.inventory_avail -= 1
      sports_bra_avail_inventory.inventory_assigned += 1
    end
    leggings_avail_inventory.save!
    tops_avail_inventory.save!
    #sports_jacket_avail_inventory.save!
    if !is_two_item
      sports_bra_avail_inventory.save!
    end
    puts "After Adjustment:"
    puts "leggings qty: #{leggings_avail_inventory.inventory_avail}"
    puts "tops qty: #{tops_avail_inventory.inventory_avail}"
    #puts "sports-jacket qty: #{sports_jacket_avail_inventory.inventory_avail}"
    if !is_two_item
      puts "sports_bra qty: #{sports_bra_avail_inventory.inventory_avail}"
    end




  end



  def get_new_subs_properties(product_id, my_sub_id)
    # Get subscription and raw_line_item_properties
    puts "In this module"
    puts "#{product_id}, #{my_sub_id}"
    my_local_sub = SubscriptionsUpdated.find_by_subscription_id(my_sub_id)
    puts "my_local_sub = #{my_local_sub.inspect}"
    my_line_items = my_local_sub.raw_line_items
    #my_line_items = OrderSize.add_missing_sub_size(my_line_items)

    my_prod = CurrentProduct.find_by_prod_id_value(product_id)
    if my_prod.nil?
      stuff_to_return = {"skip" => true}
      return stuff_to_return
    end

    #new_json = OrderSize.add_missing_sub_size(new_prod_info['properties'])
    #new_prod_info['properties'] = new_json

    #Here add size fix for allocation. If can allocate, proceed.
    #If can allocate, deduct from table inventory by size
    #Otherwise, set above to true as for my_prod.nil?
    #can_allocate = determine_allocation(my_local_sub)
    can_allocate = true
    puts "Can we allocate: #{can_allocate}"

    if can_allocate == false
      stuff_to_return = {"skip" => true}
      return stuff_to_return

    end

    


    
    next_month_product_id = my_prod.next_month_prod_id
    puts "next_month_product_id = #{next_month_product_id}"
    my_new_product_info = UpdateProduct.find_by_shopify_product_id(next_month_product_id)
    puts my_new_product_info.inspect

    

    # Now get product_collection property and loop through my_raw_line_items to set or add
    my_product_collection = my_new_product_info.product_collection
    found_collection = false
    found_unique_id = false
    found_sports_jacket = false
    found_gloves = false
    found_tops = false
    found_sports_bra = false
    found_leggings = false
    found_outfit_id = false
    tops_size = ""
    bra_size = ""
    glove_size = ""
    legging_size = ""
    sport_jacket_size = ""
    my_unique_id = SecureRandom.uuid
    my_outfit_id = my_new_product_info.shopify_product_id


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
        sport_jacket_size = mystuff['value']
      end
      if mystuff['name'] == "tops"
        tops_size = mystuff['value']
        puts "ATTENTION -- Tops SIZE = #{tops_size}"
        found_tops = true
      end
      if mystuff['name'] == "sports-bra"
        found_sports_bra = true
        bra_size = mystuff['value']
      end
      if mystuff['name'] == "leggings"
        found_leggings = true
        legging_size = mystuff['value']
      end
      if mystuff['name'] == "gloves"
        found_gloves = true
        glove_size = mystuff['value']
      end
      if mystuff['name'] == "outfit_id"
        mystuff['value'] = my_outfit_id
        found_outfit_id = true
      end

    end
    puts "my_line_items = #{my_line_items.inspect}"
    puts "---------"
    puts "tops_size = #{tops_size}"

    if found_unique_id == false
      puts "We are adding the unique_identifier to the line item properties"
      my_line_items << { "name" => "unique_identifier", "value" => my_unique_id }

    end

    #Floyd Wallace 4/29/2019 -- no longer adding sports-jacket
    #if found_sports_jacket == false
    #  puts "We are adding the sports-bra size for the sports-jacket size"
    #  my_line_items << { "name" => "sports-jacket", "value" => tops_size}
    #end

    if found_collection == false
      # only if I did not find the product_collection property in the line items do I need to add it
      puts "We are adding the product collection to the line item properties"
      my_line_items << { "name" => "product_collection", "value" => my_product_collection }
    end

    if found_tops == false
      my_line_items << { "name" => "tops", "value" => sport_jacket_size}

    end

    if found_sports_bra == false
      my_line_items << { "name" => "sports-bra", "value" => legging_size}

    end

    #10/13/2020 -- Add to EllieStging only the Mix and Match Skus
    



    #skus_for_tops = [722457990948, 764204207466, 764204207473, 764204207480, 764204112531, 764204099450, 764204099467, 764204099474, 764204099481, 764204112548, 764204099535, 764204099542, 764204099559, 764204099566].sample
    #skus_for_leggings = [764204295937, 764204295944, 764204295951, 764204295968, 764204296088, 764204296095, 764204296101, 764204296118, 764204295982, 764204295999, 764204296002, 764204296019].sample
    #skus_for_bras = [722457854059, 722457854066, 722457854073, 722457854080, 764204475001, 764204475018, 764204475025, 764204475032, 764204475049, 764204126927, 764204126934, 764204126941, 764204126958, 764204126965].sample
    #skus_for_accessories = [722457706419, 722457833986, 764204325917, 764204368143, 764204380930, 722457921331, 764204242665, 764204243839].sample
    #skus_for_equipment = [745934207032, 764204359745, 764204134199, 764204376841, 764204243822, 764204241460, 731899210309, 764204161799].sample

    #mylist = ""


    #case my_product_collection
    #when /\s2\sitem/i
    #  mylist = "#{skus_for_tops}, #{skus_for_leggings}"
    #when /\s3\sitem/i
    #  mylist = "#{skus_for_tops}, #{skus_for_leggings}, #{skus_for_bras}"
    #when /\s5\sitem/i
    #  mylist = "#{skus_for_tops}, #{skus_for_leggings}, #{skus_for_bras}, #{skus_for_accessories}, #{skus_for_equipment}"
    #when "3 MONTHS"
    #  mylist = "#{skus_for_tops}, #{skus_for_leggings}, #{skus_for_bras}, #{skus_for_accessories}, #{skus_for_equipment}"
    #else
    #  mylist = "#{skus_for_tops}, #{skus_for_leggings}, #{skus_for_bras}, #{skus_for_accessories}, #{skus_for_equipment}"
    #end




    #my_line_items << { "name" => "raw_skus", "value" => mylist}

    puts "Now my_line_items = #{my_line_items}"
    


    #if found_outfit_id == false
    #  my_line_items << { "name" => "oufit_id", "value" => my_outfit_id}
    #end

    #Floyd Wallace 4/29/2019 -- no longer adding gloves
   # if found_gloves == false
   #   if legging_size == "XS" || legging_size == "S"
   #     glove_size = "S" 
   #   elsif legging_size == "M" || legging_size == "L"
   #     glove_size = "M"
   #   elsif legging_size == "XL"
   #     glove_size = "L"
   #   else
   #     glove_size = "M"
   #     puts "Can't find the glove size off leggings, setting to M"

   #   end
   #   my_line_items << { "name" => "gloves", "value" => glove_size}

   # end


    stuff_to_return =
      if my_prod.prepaid?
        { "properties" => my_line_items }
      else
        { "sku" => my_new_product_info.sku, "product_title" => my_new_product_info.product_title, "shopify_product_id" => my_new_product_info.shopify_product_id, "shopify_variant_id" => my_new_product_info.shopify_variant_id, "properties" => my_line_items }
        #{ "sku" => my_new_product_info.sku, "product_title" => my_new_product_info.product_title, "shopify_product_id" => my_new_product_info.shopify_product_id, "shopify_variant_id" => my_new_product_info.shopify_variant_id}
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
        puts "Skipping"
        #exit
        next
      else
        puts "NEW PRODUCT INFO: #{new_prod_info}"
        Resque.logger.info "new prod info = #{new_prod_info}"
        puts "Fixing any missing sizes with library"
        Resque.logger.info "Fixing any missing sizes with library"
        if new_prod_info['product_title'] =~ /2\sitem/i
          #do nothing, don't add sizes
        else
          new_json = OrderSize.add_missing_sub_size(new_prod_info['properties'])
          new_prod_info['properties'] = new_json
        end
      puts "now sizes reflect:"
      puts new_prod_info.inspect
      Resque.logger.info "Now sizes reflect:"
      Resque.logger.info new_prod_info.inspect
      
      

        
        body = new_prod_info.to_json
        puts body.inspect
        #exit
        
        
        

        my_update_sub = HTTParty.put("https://api.rechargeapps.com/subscriptions/#{my_sub_id}", :headers => recharge_change_header, :body => body, :timeout => 80)
        puts my_update_sub.inspect
        recharge_header = my_update_sub.response["x-recharge-limit"]
        determine_limits(recharge_header, 0.65)



        Resque.logger.info my_update_sub.inspect
        puts "************************"
        puts "update_info = #{my_update_sub.inspect}"
        puts "*************************"
        #exit

        #if 7 > 3
        if my_update_sub.code == 200
          # set update flag and print success
          #Adjust inventory only here
          #adjust_inventory(sub)


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
      
      

      #Resque.logger.info "Sleeping 6 seconds"
      #sleep 6
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


  def update_missing_sports_jacket(params)
    #This one filters the subs with no sports-jacket size and with a product_collection so we just have those we want to fix.

    recharge_change_header = params['recharge_change_header']  
    my_subs = SubscriptionsUpdated.where(updated: false)
    my_now = Time.now
    number_subs_to_fix = 0
    my_subs.each do |sub|
      #puts sub.inspect
      puts "Checking #{sub.subscription_id}, #{sub.product_title}, #{sub.raw_line_items}"
      my_props = sub.raw_line_items
      found_product_collection = false
      found_sports_jacket_size = false
      top_size = ""
      my_props.each do |myp|
        puts myp.inspect
        if myp['name'] == "tops"
          top_size = myp['value']
        end
        if myp['name'] == "product_collection"
          found_product_collection = true
        end
        if myp['name'] == "sports-jacket" && !myp['value'].nil? && myp['value'] != ""
          found_sports_jacket_size = true
        end
        
      end

      if found_product_collection && !found_sports_jacket_size
        number_subs_to_fix += 1 
        my_props << { "name" => "sports-jacket", "value" => top_size}
        puts "============================================"
        puts "FIXED raw_line_item_properties = #{my_props}"
        puts "============================================"
      else
        #delete this record
        puts "Deleting subscription #{sub.subscription_id} from this table"
        local_subscription = SubscriptionsUpdated.find_by(subscription_id: sub.subscription_id)
        local_subscription.destroy

      end

    end

    puts "We have #{number_subs_to_fix} subscriptions to fix missing sports-jacket size"
  end


  def update_bad_gloves(params)
    my_now = Time.now
    recharge_change_header = params['recharge_change_header']  
    my_subs = SubscriptionsUpdated.where(updated: false)
    my_now = Time.now
    number_subs_to_fix = 0
    my_subs.each do |sub|
      puts "------"
      puts sub.inspect
      puts "-----"
      line_items = sub.raw_line_items
      #delete gloves here
      my_index = 0
      
      line_items.map do |mystuff|
        if mystuff['name'] == "gloves"
          line_items.delete_at(my_index)

        end
        my_index += 1

      end
      puts "********"
      puts line_items.inspect
      puts "********"
      send_to_recharge = { "properties" => line_items }

      body = send_to_recharge.to_json
      

      my_update_sub = HTTParty.put("https://api.rechargeapps.com/subscriptions/#{sub.subscription_id}", :headers => recharge_change_header, :body => body, :timeout => 80)
      puts my_update_sub.inspect
      recharge_header = my_update_sub.response["x-recharge-limit"]
      determine_limits(recharge_header, 0.65)
      

      if my_update_sub.code == 200
        # set update flag and print success
        sub.updated = true
        time_updated = DateTime.now
        time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
        sub.processed_at = time_updated_str
        sub.save
        puts "Updated subscription id #{sub.subscription_id}"
        #Resque.logger.info "Updated subscription id #{my_sub_id}"
      else
        # echo out error message.
        puts "WARNING -- COULD NOT UPDATE subscription #{sub.subscription_id}"
        #Resque.logger.warn "WARNING -- COULD NOT UPDATE subscription #{my_sub_id}"
      end

      #exit
     
      my_current = Time.now
      duration = (my_current - my_now).ceil
      puts "Been running #{duration} seconds"
      

      if duration > 480
        puts "Been running more than 8 minutes must exit"
        exit
      end
    
      

      
    end
    puts "All done updating subscriptions!"

  end


  def update_missing_sports_jacket_filtered(params)
    #This one uses the above filtering method to work on only those with missing sports-jacket and picks the top size
    Resque.logger = Logger.new("#{Dir.getwd}/logs/fix_sports_jacket_resque.log")
    recharge_change_header = params['recharge_change_header']  
    my_subs = SubscriptionsUpdated.where(updated: false)
    my_now = Time.now
    number_subs_to_fix = 0
    my_subs.each do |sub|
      #puts sub.inspect
      puts "Checking #{sub.subscription_id}, #{sub.product_title}, #{sub.raw_line_items}"
      my_props = sub.raw_line_items
      top_size = ""
      my_props.each do |myp|
      if myp['name'] == "tops"
        top_size = myp['value']
        end
      end
      #use picked top size from above to set the sports-jacket size in the properties
      my_props << { "name" => "sports-jacket", "value" => top_size}

      puts "-------------------------------------"
      puts "Sending this to ReCharge: #{my_props}"
      puts "-------------------------------------"
      send_to_recharge = { "properties" => my_props }.to_json

      mybody = my_props.to_json
      local_subscription_id = sub.subscription_id
      puts "Updating Subscription #{local_subscription_id}"
      
       
      my_update_sub = HTTParty.put("https://api.rechargeapps.com/subscriptions/#{local_subscription_id}", :headers => recharge_change_header, :body => send_to_recharge)
      puts my_update_sub.inspect
      Resque.logger.info my_update_sub.inspect

      if my_update_sub.code == 200
        # set update flag and print success
        sub.updated = true
        time_updated = DateTime.now
        time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
        sub.processed_at = time_updated_str
        sub.save
        puts "Updated subscription id #{local_subscription_id}"
        Resque.logger.info "Updated subscription id #{local_subscription_id}"
      else
        # echo out error message.
        puts "WARNING -- COULD NOT UPDATE subscription #{local_subscription_id}"
        Resque.logger.warn "WARNING -- COULD NOT UPDATE subscription #{local_subscription_id}"
      end

      #temp code to exit and check sub
      #exit
      puts "Sleeping 6 seconds"
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


end
