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
      SubscriptionsUpdated.delete_all
      # Now reset index
      ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
      bad_prod_id1 = "69026938898"
      bad_prod_id2 = "69026316306"
      bad_prod_id3 = "52386037778"
      bad_prod_id4 = "78480408594"
      bad_prod_id5 = "78541520914"
      bad_prod_id6 = "78657093650"
      bad_prod_id7 = "91049066514"
      bad_prod_id8 = "91049230354"
      bad_prod_id9 = "91049197586"
      bad_prod_id10 = "91236171794"
      bad_prod_id11 = "126714937362"
      bad_prod_id12 = "91235975186"
      bad_prod_id13 = "126713757714"
      bad_prod_id14 = "91236466706"
      bad_prod_id15 = "126717034514"
      bad_prod_id15 = "91236368402"
      bad_prod_id16 = "126715920402"
      bad_prod_id17 = "109303332882"
      bad_prod_id18 = "126723686418"
      bad_prod_id19 = "109301366802"
      bad_prod_id20 = "126718771218"

      bad_prod_id21 = "138427301906"
      bad_prod_id22 = "159581274130"
      bad_prod_id23 = "138427203602"
      bad_prod_id24 = "159580848146"
      bad_prod_id25 = "138427596818"
      bad_prod_id26 = "159587827730"
      bad_prod_id27 = "138427465746"
      bad_prod_id28 = "159586746386"
      bad_prod_id29 = "138427793426"
      bad_prod_id30 = "159593693202"
      bad_prod_id31 = "138427695122"
      bad_prod_id32 = "163444719634"

      monthly_box1 = "23729012754"
      monthly_box2 = "9175678162"
      monthly_box3 = "9109818066"

      #in the zone
      bad_prod_id33 = "175540207634"
      bad_prod_id34 = "175535685650"
      bad_prod_id35 = "187757723666"
      bad_prod_id36 = "187802026002"

      #set the pace
      bad_prod_id37 = "175541518354"
      bad_prod_id38 = "175541026834"
      bad_prod_id39 = "187809366034"
      bad_prod_id40 = "187809988626"

      #all star
      bad_prod_id41 = "175542632466"
      bad_prod_id42 = "175542304786"
      bad_prod_id43 = "187810512914"
      bad_prod_id44 = "187810971666"


      #desert sage
      bad_prod_id45 = "197985992722"
      bad_prod_id46 = "210212388882"
      bad_prod_id47 = "197983830034"
      bad_prod_id48 = "210212356114"

      #running wild
      bad_prod_id49 = "197986877458"
      bad_prod_id50 = "210212519954"
      bad_prod_id51 = "197986385938"
      bad_prod_id52 = "210212454418"

      #after dark
      bad_prod_id53 = "197987074066"
      bad_prod_id54 = "210212618258"
      bad_prod_id55 = "197986910226"
      bad_prod_id56 = "210212585490"

      #May Flowers
      bad_prod_id57 = "207131443218"
      bad_prod_id58 = "219709145106"
      bad_prod_id59 = "207131279378"
      bad_prod_id60 = "219709276178"

      #Wild Orchid
      bad_prod_id61 = "207131803666"
      bad_prod_id62 = "219709407250"
      bad_prod_id63 = "207131705362"
      bad_prod_id64 = "219709538322"

      #skys the limit
      bad_prod_id65 = "207132033042"
      bad_prod_id66 = "219709702162"
      bad_prod_id67 = "207131967506"
      bad_prod_id68 = "219709767698"


      subs_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and (next_charge_scheduled_at > '2018-05-31' or next_charge_scheduled_at is null)  and (shopify_product_id = \'#{bad_prod_id1}\' or shopify_product_id = \'#{bad_prod_id2}\' or shopify_product_id = \'#{bad_prod_id3}\' or shopify_product_id = \'#{bad_prod_id4}\' or shopify_product_id = \'#{bad_prod_id5}\' or shopify_product_id = \'#{bad_prod_id6}\' or shopify_product_id = \'#{bad_prod_id7}\' or shopify_product_id = \'#{bad_prod_id8}\' or shopify_product_id = \'#{bad_prod_id9}\' or shopify_product_id = \'#{bad_prod_id10}\' or  shopify_product_id = \'#{bad_prod_id11}\' or shopify_product_id = \'#{bad_prod_id12}\'  or shopify_product_id = \'#{bad_prod_id13}\' or shopify_product_id = \'#{bad_prod_id14}\' or shopify_product_id = \'#{bad_prod_id15}\' or shopify_product_id = \'#{bad_prod_id16}\' or shopify_product_id = \'#{bad_prod_id17}\' or shopify_product_id = \'#{bad_prod_id18}\' or shopify_product_id = \'#{bad_prod_id19}\' or shopify_product_id = \'#{bad_prod_id20}\' or shopify_product_id = \'#{bad_prod_id21}\' or shopify_product_id = \'#{bad_prod_id22}\' or shopify_product_id = \'#{bad_prod_id23}\' or shopify_product_id = \'#{bad_prod_id24}\' or shopify_product_id = \'#{bad_prod_id25}\' or shopify_product_id = \'#{bad_prod_id26}\' or shopify_product_id = \'#{bad_prod_id27}\' or shopify_product_id = \'#{bad_prod_id28}\' or shopify_product_id = \'#{bad_prod_id29}\' or shopify_product_id = \'#{bad_prod_id30}\'  or shopify_product_id = \'#{bad_prod_id31}\' or shopify_product_id = \'#{bad_prod_id32}\' or shopify_product_id = \'#{monthly_box1}\' or shopify_product_id = \'#{monthly_box2}\' or shopify_product_id = \'#{monthly_box3}\'  or   shopify_product_id = \'#{bad_prod_id33}\' or  shopify_product_id = \'#{bad_prod_id34}\' or  shopify_product_id = \'#{bad_prod_id35}\' or  shopify_product_id = \'#{bad_prod_id36}\' or  shopify_product_id = \'#{bad_prod_id37}\' or  shopify_product_id = \'#{bad_prod_id38}\' or  shopify_product_id = \'#{bad_prod_id39}\' or  shopify_product_id = \'#{bad_prod_id40}\' or  shopify_product_id = \'#{bad_prod_id41}\' or  shopify_product_id = \'#{bad_prod_id42}\' or  shopify_product_id = \'#{bad_prod_id43}\' or  shopify_product_id = \'#{bad_prod_id44}\' or  shopify_product_id = \'#{bad_prod_id45}\' or  shopify_product_id = \'#{bad_prod_id46}\' or  shopify_product_id = \'#{bad_prod_id47}\' or  shopify_product_id = \'#{bad_prod_id48}\' or  shopify_product_id = \'#{bad_prod_id49}\' or  shopify_product_id = \'#{bad_prod_id50}\' or  shopify_product_id = \'#{bad_prod_id51}\' or  shopify_product_id = \'#{bad_prod_id52}\' or  shopify_product_id = \'#{bad_prod_id53}\' or  shopify_product_id = \'#{bad_prod_id54}\' or  shopify_product_id = \'#{bad_prod_id55}\' or  shopify_product_id = \'#{bad_prod_id56}\' or shopify_product_id = \'#{bad_prod_id57}\' or shopify_product_id = \'#{bad_prod_id58}\' or shopify_product_id = \'#{bad_prod_id59}\' or shopify_product_id = \'#{bad_prod_id60}\' or shopify_product_id = \'#{bad_prod_id61}\' or shopify_product_id = \'#{bad_prod_id62}\' or shopify_product_id = \'#{bad_prod_id63}\' or shopify_product_id = \'#{bad_prod_id64}\' or shopify_product_id = \'#{bad_prod_id65}\' or shopify_product_id = \'#{bad_prod_id66}\' or shopify_product_id = \'#{bad_prod_id67}\' or shopify_product_id = \'#{bad_prod_id68}\')"

      
      

      # three_months_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at > '2018-01-31' and (shopify_product_id = \'#{monthly_box1}\' or shopify_product_id = \'#{monthly_box2}\' or shopify_product_id = \'#{monthly_box3}\' )"

      # This creates SubscriptionsUpdated records from normal subscriptions and
      # prepaid subscriptions NOT set to cancel:
      ActiveRecord::Base.connection.execute(subs_update)
      
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

    def load_update_products
      UpdateProduct.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('update_products')
      # my_delete = "delete from update_products"
      # @conn.exec(my_delete)
      # my_reorder = "ALTER SEQUENCE current_products_id_seq RESTART WITH 1"
      # @conn.exec(my_reorder)
      my_insert = "insert into update_products (sku, product_title, shopify_product_id, shopify_variant_id, product_collection) values ($1, $2, $3, $4, $5)"
      @conn.prepare('statement1', "#{my_insert}")
      CSV.foreach('update_products.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        # puts row.inspect
        sku = row['sku']
        product_title = row['product_title']
        shopify_product_id = row['shopify_product_id']
        shopify_variant_id = row['shopify_variant_id']
        product_collection = row['product_collection']

        @conn.exec_prepared('statement1', [sku, product_title, shopify_product_id, shopify_variant_id, product_collection])
      end
      @conn.close
    end

    def load_current_products
      CurrentProduct.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('current_products')

      # my_delete = "delete from current_products"
      # @conn.exec(my_delete)
      # my_reorder = "ALTER SEQUENCE current_products_id_seq RESTART WITH 1"
      # @conn.exec(my_reorder)
      my_insert = "insert into current_products (prod_id_key, prod_id_value, next_month_prod_id, prepaid) values ($1, $2, $3, $4)"
      @conn.prepare('statement1', "#{my_insert}")
      CSV.foreach('current_products.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
        # puts row.inspect
        prod_id_key = row['prod_id_key']
        prod_id_value = row['prod_id_value']
        next_month_prod_id = row['next_month_prod_id']
        prepaid = row['prepaid']
        @conn.exec_prepared('statement1', [prod_id_key, prod_id_value, next_month_prod_id, prepaid])
      end
      @conn.close
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
