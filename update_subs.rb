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
    end

    def get_current_products
      puts "Doing something"
      my_products = CurrentProduct.all
      my_products.each do |product|
        puts product.inspect
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

      straggler_subs_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and (next_charge_scheduled_at > \'#{my_end_month_str}\' and next_charge_scheduled_at is not null)  and (shopify_product_id = \'23729012754\' or shopify_product_id = \'9175678162\' or shopify_product_id = \'2209786298426\' or shopify_product_id = \'2209789771834\' or shopify_product_id = \'2267626373178\' or shopify_product_id = \'2227259342906\' or shopify_product_id = \'2267630239802\' or shopify_product_id = \'2267632697402\'  or shopify_product_id = \'2267637678138\' or shopify_product_id = \'2227252559930\' or shopify_product_id = \'2267641151546\' or shopify_product_id = \'2267641872442\' or shopify_product_id = \'2267622539322\' or shopify_product_id = \'2267625160762\' or shopify_product_id = \'2267638857786\' or shopify_product_id = \'2267639349306\' or shopify_product_id = \'1719720935482\' or shopify_product_id = \'2076495052858\' or shopify_product_id = \'2076520939578\')"

      


      my_end_month = Date.today.end_of_month
      my_end_month_str = my_end_month.strftime("%Y-%m-%d")
      puts "End of the month = #{my_end_month_str}"
      my_start_month_plus = Date.today 
      my_start_month_plus = my_start_month_plus >> 1
      my_start_month_plus = my_start_month_plus.end_of_month + 1
      my_start_month_plus_str = my_start_month_plus.strftime("%Y-%m-%d")
      puts "my start_month_plus_str = #{my_start_month_plus_str}"
      

      dec_2019_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and  (( next_charge_scheduled_at is not null and next_charge_scheduled_at < \'2020-01-01\' and next_charge_scheduled_at > \'2019-11-30\') or next_charge_scheduled_at is null)  and (shopify_product_id = \'2503573962810\' or shopify_product_id = \'2477581697082\' or shopify_product_id = \'2477581795386\' or shopify_product_id = \'2525988519994\' or shopify_product_id = \'2525988519994\'  or shopify_product_id = \'2525989175354\' or shopify_product_id = \'2525979639866\' or shopify_product_id = \'2525980524602\' or shopify_product_id = \'2525980524602\' or shopify_product_id = \'2525981343802\' or shopify_product_id = \'2525982425146\'  or shopify_product_id = \'2525982588986\' or shopify_product_id = \'2525982588986\' or shopify_product_id = \'2525983178810\'  or shopify_product_id = \'2514830327866\' or shopify_product_id = \'2514830327866\' or shopify_product_id = \'2514830491706\' or shopify_product_id = \'2514830852154\' or shopify_product_id = \'2227262881850\' or shopify_product_id = \'2496307560506\' or shopify_product_id = \'2494099554362\' or shopify_product_id = \'2494100176954\' or shopify_product_id = \'2477579599930\' or shopify_product_id = \'2503579500602\' or shopify_product_id = \'2457952845882\' or shopify_product_id = \'2457953173562\' or shopify_product_id = \'2525983866938\' or shopify_product_id = \'2525983998010\' or shopify_product_id = \'2525984456762\' or shopify_product_id = \'2525985210426\' or shopify_product_id = \'2525985439802\' or shopify_product_id = \'2525987668026\' or  shopify_product_id = \'2267622539322\' or shopify_product_id = \'2514832261178\' or shopify_product_id =  \'2514833440826\'  or shopify_product_id =  \'2514833866810 \'  or  shopify_product_id = \'2525970399290\' or shopify_product_id = \'2525970530362\' or shopify_product_id =  \'2525978525754\'  or shopify_product_id = \'2496309329978\' or shopify_product_id =  \'2494104535098\' )"

      jan_2020_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and  ( next_charge_scheduled_at is not null and next_charge_scheduled_at < \'2020-02-01\' and next_charge_scheduled_at > \'2019-12-31\')  and (shopify_product_id = \'2525980524602\' or shopify_product_id = \'2525981343802\' or shopify_product_id = \'4320734412858\' or shopify_product_id = \'4320734609466\' or shopify_product_id = \'4320734904378\'  or shopify_product_id = \'2514830327866\' or shopify_product_id = \'2514830491706\' or shopify_product_id = \'2514830852154\' or shopify_product_id = \'4320724910138\' or shopify_product_id = \'4320725106746\' or shopify_product_id = \'4320726024250\'  or shopify_product_id = \'4320731660346\' or shopify_product_id = \'4320732905530\' or shopify_product_id = \'2496308281402\'  or shopify_product_id = \'2494101356602\' or shopify_product_id = \'2494101553210\' or shopify_product_id = \'2494103453754\' or shopify_product_id = \'2514826788922\' or shopify_product_id = \'4320735559738\' or shopify_product_id = \'4320735985722\' or shopify_product_id = \'2525983998010\' or shopify_product_id = \'2525984456762\' or shopify_product_id = \'4320727367738\' or shopify_product_id = \'4320729464890\' or shopify_product_id = \'4320730775610\' or shopify_product_id = \'2514833440826\' or shopify_product_id = \'2514833866810\' or shopify_product_id = \'2525970399290\' or shopify_product_id = \'2525970530362\' or shopify_product_id = \'2525978525754\' or shopify_product_id = \'2477583237178\' or shopify_product_id = \'2494104698938\' or  shopify_product_id = \'4320726253626\' or shopify_product_id = \'4320726581306\' or shopify_product_id =  \'4320727072826\'  )"

      jan_2020_nulls_monthly = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and  ( next_charge_scheduled_at is  null )  and product_title not ilike \'3%month%\' "

      

      ellie_staging_monthly = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE'   and ( product_title  ilike \'boss%babe%2%\'  or product_title ilike \'gear%up%2%\') and next_charge_scheduled_at > '2020-03-24' and next_charge_scheduled_at < '2020-04-01' limit 2200"

      #SubscriptionsUpdated.delete_all
      # Now reset index
      #ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      #puts "Setting up Ellie Staging for Ellie picks monthly"
      #ActiveRecord::Base.connection.execute(ellie_staging_monthly)
      #puts "all done ..."
      #exit

      ellie_feb_new_subs_dec_2019 = " insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and  ( next_charge_scheduled_at is not null and next_charge_scheduled_at < \'2020-03-01\' and next_charge_scheduled_at > \'2020-01-31\' and created_at < \'2020-01-01\' and created_at > \'2019-11-30\' and product_title not ilike \'3%month%\') "

      ellie_feb_new_subs_jan_2020 = " insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and  ( next_charge_scheduled_at is not null and next_charge_scheduled_at < \'2020-03-01\' and next_charge_scheduled_at > \'2020-01-31\' and created_at < \'2020-02-01\' and created_at > \'2019-12-31\' and product_title not ilike \'3%month%\') "

      ellie_mar_new_subs_feb_2020 = " insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and  ( next_charge_scheduled_at is not null and next_charge_scheduled_at < \'2020-04-01\' and next_charge_scheduled_at > \'2020-02-29\' and created_at < \'2020-03-01\' and created_at > \'2020-01-31\' and product_title not ilike \'3%month%\' and product_title not ilike \'%2%item\') "

      #SubscriptionsUpdated.delete_all
      # Now reset index
      #ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      #puts "Setting up New created Feb monthly"
      #ActiveRecord::Base.connection.execute(ellie_mar_new_subs_feb_2020)
      #puts "all done ..."



      #move Berry Crush, Paradise Cove, City Limits, Clean Slate, Ivy League, and Crunch Time to Canyon Sunset
      jan_2020_move_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and  ( next_charge_scheduled_at is not null and next_charge_scheduled_at < \'2020-02-01\' and next_charge_scheduled_at > \'2019-12-31\')   and (shopify_product_id = \'4366057209914\' or shopify_product_id = \'4366057406522\' or shopify_product_id = \'4366057963578\' or shopify_product_id = \'4366060453946\' or shopify_product_id = \'4366061174842\'  or shopify_product_id = \'4366066024506\' or shopify_product_id = \'4373264597050\' or shopify_product_id = \'4373264957498\' or shopify_product_id = \'4373306998842\' or shopify_product_id = \'4366079459386\' or shopify_product_id = \'4366079787066\'  or shopify_product_id = \'4366080311354\' or shopify_product_id = \'4366077132858\' or shopify_product_id = \'4366077591610\'  or shopify_product_id = \'4366079098938\' or shopify_product_id = \'4366058225722\' or shopify_product_id = \'4366058782778\' or shopify_product_id = \'4366059143226\'  ) and created_at > \'2019-11-30\'"


      

      #jan_2020_prepaid_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at >= '2020-01-01'   and (product_title ilike \'3%month%\' )"

      #Null Prepaids
      feb_2020_prepaid_update_null = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at is null   and (product_title ilike \'3%month%\' )"

      #Charging next month prepaid, no pending orders until charged
      feb_2020_prepaid_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at > '2020-02-29' and next_charge_scheduled_at < '2020-04-01'   and (product_title ilike \'3%month%\' )"

      #prepaid charging past Feb
      feb_2020_prepaid_future = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at > '2020-03-31'  and (product_title ilike \'3%month%\' )"


      #puts "Setting up Mar Prepaid Null"
      #ActiveRecord::Base.connection.execute(feb_2020_prepaid_update_null)
     # ActiveRecord::Base.connection.execute(feb_2020_prepaid_update)
      #ActiveRecord::Base.connection.execute(feb_2020_prepaid_future)
     # puts "all done ..."

     #Non 2 item overflow Month to Month
     feb_2020_non2_item_overflow = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at > \'2020-01-31\' and next_charge_scheduled_at < \'2020-03-01\'  and (product_title not ilike \'3%month%\'  and product_title not ilike \'%2%item%\' and product_title not ilike \'second%skin%\' and product_title not ilike \'boss%babe%\' and product_title not ilike \'supernova%\'  and product_title not ilike \'hidden%gem%\' and product_title not ilike \'bayside%breeze%\' and product_title not ilike \'cupids%kiss%\' and product_title not ilike \'knockout%\' and product_title not ilike \'ready%set%go%\' and product_title not ilike \'out%of%the%blue%\') "

     #puts "Setting up Feb Non 2 Item overflow month to month"
     #ActiveRecord::Base.connection.execute(feb_2020_non2_item_overflow)
     
     #puts "all done ..."

     #Non 2 item nulls Month to Month
     feb_2020_non2_item_nulls = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at is null  and (product_title not ilike \'3%month%\'  and product_title not ilike \'%2%item%\' and product_title not ilike \'second%skin%\' and product_title not ilike \'boss%babe%\' and product_title not ilike \'supernova%\'  and product_title not ilike \'hidden%gem%\' and product_title not ilike \'bayside%breeze%\' and product_title not ilike \'cupids%kiss%\' and product_title not ilike \'knockout%\' and product_title not ilike \'ready%set%go%\' and product_title not ilike \'out%of%the%blue%\') "

     #puts "Setting up Feb Non 2 Item overflow month to month NULLS"
     #ActiveRecord::Base.connection.execute(feb_2020_non2_item_nulls)
     
     #puts "all done ..." 

     #Non 2 item late Jan rollover
     feb_2020_non2_item_late = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at =\'2020-02-29'  and (product_title not ilike \'3%month%\'  and product_title not ilike \'%2%item%\' and product_title not ilike \'second%skin%\' and product_title not ilike \'boss%babe%\' and product_title not ilike \'supernova%\'  and product_title not ilike \'hidden%gem%\' and product_title not ilike \'bayside%breeze%\' and product_title not ilike \'cupids%kiss%\' and product_title not ilike \'knockout%\' and product_title not ilike \'ready%set%go%\' and product_title not ilike \'out%of%the%blue%\') "

     #puts "Setting up Feb Non 2 Item late to month "
     #ActiveRecord::Base.connection.execute(feb_2020_non2_item_late)
     
     #puts "all done ..." 


     #March 2020 Overflow
     # first delete all records
     #SubscriptionsUpdated.delete_all
     #Now reset index
     #ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
     march_2020_overflow = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and ( next_charge_scheduled_at > \'2020-02-29\' and next_charge_scheduled_at < \'2020-04-01\')  and (product_title not ilike \'3%month%\')   and ( product_title  ilike \'bayside%breeze%\' or product_title ilike \'boss%babe%\' or product_title ilike \'clean%slate%\' or product_title ilike \'comfort%zone%\' or product_title ilike \'crunch%time%\' or product_title ilike \'cupid%kiss%\' or product_title ilike \'gear%up%\' or product_title ilike \'hidden%gem%\' or product_title ilike \'ivy%league%\' or product_title ilike \'knockout%\' or product_title ilike \'out%blue%\' or product_title ilike \'paradise%\' or product_title ilike \'ready%set%\' or product_title ilike \'second%skin%\' or product_title ilike \'supernova%\' or product_title ilike \'ultraviolet%\') "

     march_2020_overflow_nulls = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and ( next_charge_scheduled_at is null )  and (product_title not ilike \'3%month%\')   and ( product_title  ilike \'bayside%breeze%\' or product_title ilike \'boss%babe%\' or product_title ilike \'clean%slate%\' or product_title ilike \'comfort%zone%\' or product_title ilike \'crunch%time%\' or product_title ilike \'cupid%kiss%\' or product_title ilike \'gear%up%\' or product_title ilike \'hidden%gem%\' or product_title ilike \'ivy%league%\' or product_title ilike \'knockout%\' or product_title ilike \'out%blue%\' or product_title ilike \'paradise%\' or product_title ilike \'ready%set%\' or product_title ilike \'second%skin%\' or product_title ilike \'supernova%\' or product_title ilike \'ultraviolet%\') "


     #ActiveRecord::Base.connection.execute(march_2020_overflow)
     #ActiveRecord::Base.connection.execute(march_2020_overflow_nulls)

     #puts "all done with overflow March..." 

     #April 2020 Ghost Allocation
     april2020_ghost2 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, created_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE'   and (product_title not ilike \'3%month%\')  and ( product_title not ilike \'back%basic%\' and product_title not ilike \'dream%on%\' and product_title not ilike \'kaleidoscope%\' and product_title not ilike \'violet%rhapsody%\' and product_title not ilike \'glow%getter%\' and product_title not ilike \'matcha%cha%\' ) and   created_at < \'2020-03-01\' and next_charge_scheduled_at > \'2020-04-19\' and next_charge_scheduled_at < \'2020-04-30\' limit 233 "

     april2020_ghost = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, created_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE'   and (product_title not ilike \'3%month%\')  and ( product_title  ilike \'back%basic%\' or product_title  ilike \'dream%on%\' or product_title  ilike \'kaleidoscope%\' or product_title  ilike \'violet%rhapsody%\' or product_title  ilike \'glow%getter%\' or product_title  ilike \'matcha%cha%\' ) and   created_at < \'2020-03-01\' and next_charge_scheduled_at > \'2020-04-19\' and next_charge_scheduled_at < \'2020-04-30\'  "

     april2020_new_march_fix = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, created_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE'   and (product_title not ilike \'3%month%\')  and ( product_title  ilike \'back%basic%\' or product_title  ilike \'dream%on%\' or product_title  ilike \'kaleidoscope%\' or product_title  ilike \'violet%rhapsody%\' or product_title  ilike \'glow%getter%\' or product_title  ilike \'matcha%cha%\' ) and   created_at < \'2020-04-01\' and created_at > \'2020-02-29\' and next_charge_scheduled_at > \'2020-03-31\' and next_charge_scheduled_at < \'2020-05-01\'  "

     april2020_new_march = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, created_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE'   and (product_title not ilike \'3%month%\' and product_title not ilike \'city%limit%\' )  and    created_at < \'2020-04-01\' and created_at > \'2020-02-29\' and next_charge_scheduled_at > \'2020-03-31\' and next_charge_scheduled_at < \'2020-05-01\' limit 1000 "

     april2020_straggler = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, created_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE'   and (product_title not ilike \'3%month%\' and product_title not ilike \'back%basic%\' and product_title not ilike \'dream%on%\' and product_title not ilike \'kaleidoscope%\' and product_title not ilike \'violet%rhapsody%\' and product_title not ilike \'glow%getter%\' and product_title not ilike \'matcha%cha%\'  and product_title not ilike \'cupid%kiss%\' and product_title not ilike \'city%limit%\'  and product_title not ilike \'ellie%pick%\' and  (next_charge_scheduled_at > \'2020-03-31\' or next_charge_scheduled_at is null)  ) "

     may2020_march_new_subs = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, created_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE'   and (product_title not ilike \'3%month%\' and  created_at > \'2020-02-29\' and created_at < \'2020-04-01\' and (next_charge_scheduled_at > \'2020-04-30\' and next_charge_scheduled_at < \'2020-06-01\' )  ) "

     may2020_prepaid_not_billing_next_month = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, created_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE'   and (product_title ilike \'3%month%\'  and ( next_charge_scheduled_at > \'2020-05-31\' and next_charge_scheduled_at is not null )  )"

     may2020_prepaid_billing_in_may = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, created_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE'   and (product_title ilike \'3%month%\'  and ( next_charge_scheduled_at > \'2020-04-30\' and next_charge_scheduled_at < \'2020-06-01\' )  )"

     may_2020_nulls = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and product_title not ilike \'3%month%\' and ( next_charge_scheduled_at is null )   "

     may_2020_may5_may6_unallocated = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and product_title not ilike \'3%month%\' and  product_title not ilike \'paradise%cove%\' and product_title not ilike \'pacific%mist%\' and product_title not ilike \'citrus%\' and product_title not ilike \'natural%\' and product_title not ilike \'calypso%\' and product_title not ilike \'pinky%\' and product_title not ilike \'tie%game%\' and product_title not ilike \'golden%girl%\' and product_title not ilike \'spring%action%\' and ( next_charge_scheduled_at > \'2020-05-04\' and next_charge_scheduled_at < \'2020-05-07\' )   "


     may_2020_may7_later_unallocated = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and product_title not ilike \'3%month%\' and  product_title not ilike \'paradise%cove%\' and product_title not ilike \'pacific%mist%\' and product_title not ilike \'citrus%\' and product_title not ilike \'natural%\' and product_title not ilike \'calypso%\' and product_title not ilike \'pinky%\' and product_title not ilike \'tie%game%\' and product_title not ilike \'golden%girl%\' and product_title not ilike \'spring%action%\' and ( next_charge_scheduled_at > \'2020-05-06\' and next_charge_scheduled_at < \'2020-06-01\' )   "


     # first delete all records
     SubscriptionsUpdated.delete_all
     #Now reset index
     ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
     ActiveRecord::Base.connection.execute(may_2020_may7_later_unallocated)
     #ActiveRecord::Base.connection.execute(april2020_ghost2)
     #ActiveRecord::Base.connection.execute(april2020_new_march_fix)
     #ActiveRecord::Base.connection.execute(april2020_new_march)
     puts "All done with april2020 straggler set up"


     april_2020_prepaid = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, created_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at > '2020-03-31'  and (product_title ilike \'3%month%\' )"
     #SubscriptionsUpdated.delete_all
     #ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
     #ActiveRecord::Base.connection.execute(april_2020_prepaid)
     #puts "All done with april2020 prepaid set up"



     #Feb 2020 Overflow non 2 item
     feb_2020_non_2_item_overflow = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at > \'2020-01-31\' and next_charge_scheduled_at < \'2020-03-01\'  and (product_title not ilike \'3%month%\'  and product_title not ilike \'%2%item%\' and product_title not ilike \'second%skin%\' and product_title not ilike \'boss%babe%\') "



      

      dec_2019_late_prepaid = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items)select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions where (subscription_id = \'49398229\' or subscription_id = \'49351767\' or subscription_id = \'49343544\'
      or subscription_id = \'49335559\' or subscription_id = \'49331336\' or subscription_id = \'48165224\' or subscription_id = \'47573227\' or subscription_id = \'55826719\' or subscription_id = \'55785609\' or subscription_id = \'55762085\' or subscription_id = \'55760703\' or subscription_id = \'55748148\' or subscription_id = \'55746968\' or subscription_id = \'55744054\' or subscription_id = \'55742379\' or subscription_id = \'53251436\' or subscription_id = \'51490664\')"


    
      

     # 15 Medium tops, 15 large tops, 15 XL tops customers from Clean slate to Good Karma
#   15 Medium tops, 15 large tops, 15 XL tops customers from City Limits to Good Karma
#·       15 Medium tops, 15 large tops, 15 XL tops customers from Ivy League to Good Karma
#·       15 Medium tops, 15 large tops, 15 XL tops customers from City Limits to Good Karma
#·       250 Medium tops from Berry Crush to Good Karma
      sql_statement1 =  "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-02-01\' and subscriptions.next_charge_scheduled_at > \'2019-12-31\')   and sub_collection_sizes.product_collection ilike \'clean%slate%\' and sub_collection_sizes.tops = \'M\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 15"

      sql_statement2 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-02-01\' and subscriptions.next_charge_scheduled_at > \'2019-12-31\')   and sub_collection_sizes.product_collection ilike \'clean%slate%\' and sub_collection_sizes.tops = \'L\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 15"

      sql_statement3 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-02-01\' and subscriptions.next_charge_scheduled_at > \'2019-12-31\')   and sub_collection_sizes.product_collection ilike \'clean%slate%\' and sub_collection_sizes.tops = \'XL\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 15"

      sql_statement4 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-02-01\' and subscriptions.next_charge_scheduled_at > \'2019-12-31\')   and sub_collection_sizes.product_collection ilike \'city%limit%\' and sub_collection_sizes.tops = \'M\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 15"

      sql_statement5 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-02-01\' and subscriptions.next_charge_scheduled_at > \'2019-12-31\')   and sub_collection_sizes.product_collection ilike \'city%limit%\' and sub_collection_sizes.tops = \'L\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 15"

      sql_statement6 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-02-01\' and subscriptions.next_charge_scheduled_at > \'2019-12-31\')   and sub_collection_sizes.product_collection ilike \'city%limit%\' and sub_collection_sizes.tops = \'XL\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 15"

      sql_statement7 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-02-01\' and subscriptions.next_charge_scheduled_at > \'2019-12-31\')   and sub_collection_sizes.product_collection ilike \'ivy%league%\' and sub_collection_sizes.tops = \'M\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 15"

      sql_statement8 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-02-01\' and subscriptions.next_charge_scheduled_at > \'2019-12-31\')   and sub_collection_sizes.product_collection ilike \'ivy%league%\' and sub_collection_sizes.tops = \'L\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 15"

      sql_statement9 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-02-01\' and subscriptions.next_charge_scheduled_at > \'2019-12-31\')   and sub_collection_sizes.product_collection ilike \'berry%crush%\' and sub_collection_sizes.tops = \'M\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 250"
      #Above, there are no XL tops in Ivy League


      #ActiveRecord::Base.connection.execute(sql_statement1)
      #ActiveRecord::Base.connection.execute(sql_statement2)
      #ActiveRecord::Base.connection.execute(sql_statement3)
      #ActiveRecord::Base.connection.execute(sql_statement4)
      #ActiveRecord::Base.connection.execute(sql_statement5)
      #ActiveRecord::Base.connection.execute(sql_statement6)
      #ActiveRecord::Base.connection.execute(sql_statement7)
      #ActiveRecord::Base.connection.execute(sql_statement8)
      #ActiveRecord::Base.connection.execute(sql_statement9)


      sql_move1 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-02-01\' and subscriptions.next_charge_scheduled_at > \'2019-12-31\')   and sub_collection_sizes.product_collection ilike \'berry%crush%\' and sub_collection_sizes.tops = \'L\' and sub_collection_sizes.leggings = \'L\' and sub_collection_sizes.sports_bra = \'L\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 250"
      #ActiveRecord::Base.connection.execute(sql_move1)

      sql_move2 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-04-01\' and subscriptions.next_charge_scheduled_at > \'2020-02-29\')   and sub_collection_sizes.product_collection ilike \'under%radar%\' and sub_collection_sizes.tops = \'XS\' and sub_collection_sizes.leggings = \'XS\' and sub_collection_sizes.sports_bra = \'XS\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 15"

      sql_move3 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-04-01\' and subscriptions.next_charge_scheduled_at > \'2020-02-29\')   and sub_collection_sizes.product_collection ilike \'bahama%babe%\' and sub_collection_sizes.tops = \'XS\' and sub_collection_sizes.leggings = \'XS\' and sub_collection_sizes.sports_bra = \'XS\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 10"

      sql_move4 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-04-01\' and subscriptions.next_charge_scheduled_at > \'2020-02-29\')   and sub_collection_sizes.product_collection ilike \'blue%skie%\' and  sub_collection_sizes.sports_bra = \'M\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 500"

      sql_move4 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-04-01\' and subscriptions.next_charge_scheduled_at > \'2020-02-29\')   and sub_collection_sizes.product_collection ilike \'blue%skie%\' and  sub_collection_sizes.sports_bra = \'XS\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 65"

      sql_move5 = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, customer_id, subscriptions.updated_at, subscriptions.next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions, sub_collection_sizes where status = 'ACTIVE' and  ( subscriptions.next_charge_scheduled_at is not null and subscriptions.next_charge_scheduled_at < \'2020-04-01\' and subscriptions.next_charge_scheduled_at > \'2020-02-29\')   and sub_collection_sizes.product_collection ilike \'blue%skie%\' and  sub_collection_sizes.sports_bra = \'XL\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id limit 200"

      #SubscriptionsUpdated.delete_all
      # Now reset index
      #ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      #puts "Setting up move 15 XS bras under the radar"
      #ActiveRecord::Base.connection.execute(sql_move4)
      #puts "all done ..."

      
      #ActiveRecord::Base.connection.execute(july_2019_update)
      #ActiveRecord::Base.connection.execute(starstruck_update)

      # ActiveRecord::Base.connection.execute(three_months_update)

      # This creates SubscriptionsUpdated records from cancelled subscriptions
      # that have orders that are not cancelled. 
      #not_canceled_orders_from_boxes(
      #  monthly_box1, monthly_box2, monthly_box3
      #).each do |order|
      #  subscription = Subscription.find_by_customer_id(order.customer_id)
      #  next unless subscription&.status&.downcase == 'cancelled'
      #  next unless [monthly_box1, monthly_box2, monthly_box3].include?(subscription.shopify_product_id)
      #  SubscriptionsUpdated.create(
      #    subscription_id: subscription.subscription_id,
      #    customer_id: subscription.customer_id,
      #    updated_at: subscription.updated_at,
      #    next_charge_scheduled_at: subscription.next_charge_scheduled_at,
      #    product_title: subscription.product_title,
      #    status: subscription.status,
      #    sku: subscription.sku,
      #    shopify_product_id: subscription.shopify_product_id,
      #    shopify_variant_id: subscription.shopify_variant_id,
      #    raw_line_items: subscription.raw_line_item_properties
      #  )
      #end
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
      CSV.foreach('update_products_may2020_ellie_picks.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
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
      my_insert = "insert into current_products (prod_id_key, prod_id_value, next_month_prod_id, prepaid) values ($1, $2, $3, $4)"
      @conn.prepare('statement1', "#{my_insert}")
      CSV.foreach('may2020_may_ellie_picks.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
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
