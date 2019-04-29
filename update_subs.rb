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

      #Rose All Day
      bad_prod_id69 = "224674119698"
      bad_prod_id70 = "224674086930"
      bad_prod_id71 = "224675037202"
      bad_prod_id72 = "224674971666"

      #Weekend Warrior
      bad_prod_id73 = "224674447378"
      bad_prod_id74 = "224675364882"
      bad_prod_id75 = "224674381842"
      bad_prod_id76 = "224675299346"

      #Back to Black
      bad_prod_id77 = "224674316306"
      bad_prod_id78 = "224675233810"
      bad_prod_id79 = "224674283538"
      bad_prod_id80 = "224675135506"

      #Print Paradise
      bad_prod_id81 = "1446651330618"
      bad_prod_id82 = "1508549427258"
      bad_prod_id83 = "1446647234618"
      bad_prod_id84 = "1508553392186"

      #Seeing Stars
      bad_prod_id85 = "1446660702266"
      bad_prod_id86 = "1508540219450"
      bad_prod_id87 = "1446656999482"
      bad_prod_id88 = "1508544643130"

      #Vitamin Sea
      bad_prod_id89 = "1446669287482"
      bad_prod_id90 = "1508523147322"
      bad_prod_id91 = "1446664306746"
      bad_prod_id92 = "1508537106490"

      #Meet Your Match
      bad_prod_id93 = "1719732535354"
      bad_prod_id94 = "1719728111674"
      bad_prod_id95 = "1778624921658"
      bad_prod_id96 = "1778619449402"

      #Tough Luxe
      bad_prod_id97 = "1719724507194"
      bad_prod_id98 = "1719720935482"
      bad_prod_id99 = "1778637897786"
      bad_prod_id100 = "1778635964474"

      #Power Surge
      bad_prod_id101 = "1719715201082"
      bad_prod_id102 = "1719710810170"
      bad_prod_id103 = "1778644779066"
      bad_prod_id104 = "1778643304506"

      #Vinyasa Vibes
      bad_prod_id105 = "1828555587642"
      bad_prod_id106 = "1828595367994"
      bad_prod_id107 = "1828550213690"
      bad_prod_id108 = "1828594090042"

      #Give Me Zen
      bad_prod_id109 = "1828557127738"
      bad_prod_id110 = "1828596514874"
      bad_prod_id111 = "1828556308538"
      bad_prod_id112 = "1828595990586"

      #Love and Light
      bad_prod_id113 = "1828559061050"
      bad_prod_id114 = "1828598218810"
      bad_prod_id115 = "1828558078010"
      bad_prod_id116 = "1828596645946"

      #Think Pink
      bad_prod_id117 = "1918032609338"
      bad_prod_id118 = "1918033133626"
      bad_prod_id119 = "1930401415226"
      bad_prod_id120 = "1924814274618"


      #Lounge Life
      bad_prod_id121 = "1918047453242"
      bad_prod_id122 = "1918045159482"
      bad_prod_id123 = "1924849664058"
      bad_prod_id124 = "1930396663866"


      #Street Dreams
      bad_prod_id125 = "1918042636346"
      bad_prod_id126 = "1918039687226"
      bad_prod_id127 = "1924806180922"
      bad_prod_id128 = "1924801101882"

      #EllieStaging testing products
      #bad_prod_id129 = "1494850863155"
      #bad_prod_id130 = "1494851289139"
      #bad_prod_id131 = "1494833725491"
      #bad_prod_id132 = "1452468994099"
      #bad_prod_id133 = "1478518636595"
      #bad_prod_id134 = "1452468076595"
      #bad_prod_id135 = "1452467978291"
      #bad_prod_id136 = "1452468731955"
      #bad_prod_id137 = "1452469321779"
      #bad_prod_id138 = "1401707069491"
      #bad_prod_id139 = "1479235829811"
      #end Elliestaging testing products -- remove for production


      #November Products

      #Wrap Me up
      bad_prod_id129 = "2076469657658"
      bad_prod_id130 = "2089102573626"
      bad_prod_id131 = "2076477653050"
      bad_prod_id132 = "2089102114874"

      #Color Theory
      bad_prod_id133 = "2089364193338"
      bad_prod_id134 = "2076342452282"
      bad_prod_id135 = "2089098313786"
      bad_prod_id136 = "2076357886010"

      #Wine & Roses
      bad_prod_id137 = "2076495052858"
      bad_prod_id138 = "2092149178426"
      bad_prod_id139 = "2076520939578"
      bad_prod_id140 = "2092150227002"

      #December Products
      #Street Smarts
      bad_prod_id141 = "2154512613434"
      bad_prod_id142 = "2144938426426"
      bad_prod_id143 = "2156332908602"
      bad_prod_id144 = "2188207980602"

      #Street Smarts2
      bad_prod_id145 = "2188530778170"
      bad_prod_id146 = "2188532875322"
      bad_prod_id147 = "2196272807994"
      bad_prod_id148 = "2188543328314"

      #Snug Life
      bad_prod_id149 = "2163296698426"
      bad_prod_id150 = "2154515857466"
      bad_prod_id151 = "2188491882554"
      bad_prod_id152 = "2188496666682"

      #Never Basic
      bad_prod_id153 = "2185227010106"
      bad_prod_id154 = "2185229860922"
      bad_prod_id155 = "2188525928506"
      bad_prod_id156 = "2188527599674"

      #Blush Crush
      bad_prod_id157 = "2154559995962"
      bad_prod_id158 = "2154524049466"
      bad_prod_id159 = "2188518850618"
      bad_prod_id160 = "2188520521786"

      #Jan 2019 products

      #Fierce and Floral
      bad_prod_id161 = "2227262881850"
      bad_prod_id162 = "2236718448698"
      bad_prod_id163 = "2227259342906"
      bad_prod_id164 = "2237890625594"

      #Knot Your Average
      bad_prod_id165 = "2227252559930"
      bad_prod_id166 = "2237892132922"
      bad_prod_id167 = "2227246661690"
      bad_prod_id168 = "2237892952122"

      #Street Dreams
      bad_prod_id167 = "1918042636346"
      bad_prod_id168 = "1924806180922"
      bad_prod_id169 = "1918039687226"
      bad_prod_id170 = "1924801101882"

      #True Blue
      bad_prod_id171 = "2226409963578"
      bad_prod_id172 = "2237897441338"
      bad_prod_id173 = "2226391941178"
      bad_prod_id174 = "2237898391610"

      #Peace & Pastels
      bad_prod_id175 = "2226413174842"
      bad_prod_id176 = "2237902815290"
      bad_prod_id177 = "2226411667514"
      bad_prod_id178 = "2237903110202"

      #Street Smarts
      bad_prod_id179 = "2188530778170"
      bad_prod_id180 = "2188532875322"

      #Alternate Street Smarts
      bad_prod_id181 = "2154512613434"

      #Street Smarts 2
      bad_prod_id182 = "2188530778170"
      bad_prod_id183 = "2188532875322"


      alt_subs_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' "

      subs_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and (next_charge_scheduled_at > '2019-01-31' and next_charge_scheduled_at is not null)  and (shopify_product_id = \'#{bad_prod_id1}\' or shopify_product_id = \'#{bad_prod_id2}\' or shopify_product_id = \'#{bad_prod_id3}\' or shopify_product_id = \'#{bad_prod_id4}\' or shopify_product_id = \'#{bad_prod_id5}\' or shopify_product_id = \'#{bad_prod_id6}\' or shopify_product_id = \'#{bad_prod_id7}\' or shopify_product_id = \'#{bad_prod_id8}\' or shopify_product_id = \'#{bad_prod_id9}\' or shopify_product_id = \'#{bad_prod_id10}\' or  shopify_product_id = \'#{bad_prod_id11}\' or shopify_product_id = \'#{bad_prod_id12}\'  or shopify_product_id = \'#{bad_prod_id13}\' or shopify_product_id = \'#{bad_prod_id14}\' or shopify_product_id = \'#{bad_prod_id15}\' or shopify_product_id = \'#{bad_prod_id16}\' or shopify_product_id = \'#{bad_prod_id17}\' or shopify_product_id = \'#{bad_prod_id18}\' or shopify_product_id = \'#{bad_prod_id19}\' or shopify_product_id = \'#{bad_prod_id20}\' or shopify_product_id = \'#{bad_prod_id21}\' or shopify_product_id = \'#{bad_prod_id22}\' or shopify_product_id = \'#{bad_prod_id23}\' or shopify_product_id = \'#{bad_prod_id24}\' or shopify_product_id = \'#{bad_prod_id25}\' or shopify_product_id = \'#{bad_prod_id26}\' or shopify_product_id = \'#{bad_prod_id27}\' or shopify_product_id = \'#{bad_prod_id28}\' or shopify_product_id = \'#{bad_prod_id29}\' or shopify_product_id = \'#{bad_prod_id30}\'  or shopify_product_id = \'#{bad_prod_id31}\' or shopify_product_id = \'#{bad_prod_id32}\' or shopify_product_id = \'#{monthly_box1}\' or shopify_product_id = \'#{monthly_box2}\' or shopify_product_id = \'#{monthly_box3}\'  or   shopify_product_id = \'#{bad_prod_id33}\' or  shopify_product_id = \'#{bad_prod_id34}\' or  shopify_product_id = \'#{bad_prod_id35}\' or  shopify_product_id = \'#{bad_prod_id36}\' or  shopify_product_id = \'#{bad_prod_id37}\' or  shopify_product_id = \'#{bad_prod_id38}\' or  shopify_product_id = \'#{bad_prod_id39}\' or  shopify_product_id = \'#{bad_prod_id40}\' or  shopify_product_id = \'#{bad_prod_id41}\' or  shopify_product_id = \'#{bad_prod_id42}\' or  shopify_product_id = \'#{bad_prod_id43}\' or  shopify_product_id = \'#{bad_prod_id44}\' or  shopify_product_id = \'#{bad_prod_id45}\' or  shopify_product_id = \'#{bad_prod_id46}\' or  shopify_product_id = \'#{bad_prod_id47}\' or  shopify_product_id = \'#{bad_prod_id48}\' or  shopify_product_id = \'#{bad_prod_id49}\' or  shopify_product_id = \'#{bad_prod_id50}\' or  shopify_product_id = \'#{bad_prod_id51}\' or  shopify_product_id = \'#{bad_prod_id52}\' or  shopify_product_id = \'#{bad_prod_id53}\' or  shopify_product_id = \'#{bad_prod_id54}\' or  shopify_product_id = \'#{bad_prod_id55}\' or  shopify_product_id = \'#{bad_prod_id56}\' or shopify_product_id = \'#{bad_prod_id57}\' or shopify_product_id = \'#{bad_prod_id58}\' or shopify_product_id = \'#{bad_prod_id59}\' or shopify_product_id = \'#{bad_prod_id60}\' or shopify_product_id = \'#{bad_prod_id61}\' or shopify_product_id = \'#{bad_prod_id62}\' or shopify_product_id = \'#{bad_prod_id63}\' or shopify_product_id = \'#{bad_prod_id64}\' or shopify_product_id = \'#{bad_prod_id65}\' or shopify_product_id = \'#{bad_prod_id66}\' or shopify_product_id = \'#{bad_prod_id67}\' or shopify_product_id = \'#{bad_prod_id69}\' or shopify_product_id = \'#{bad_prod_id70}\' or shopify_product_id = \'#{bad_prod_id71}\' or shopify_product_id = \'#{bad_prod_id72}\' or shopify_product_id = \'#{bad_prod_id73}\' or shopify_product_id = \'#{bad_prod_id74}\' or shopify_product_id = \'#{bad_prod_id75}\' or shopify_product_id = \'#{bad_prod_id76}\' or shopify_product_id = \'#{bad_prod_id77}\' or shopify_product_id = \'#{bad_prod_id78}\' or shopify_product_id = \'#{bad_prod_id79}\' or shopify_product_id = \'#{bad_prod_id80}\' or shopify_product_id = \'#{bad_prod_id81}\' or shopify_product_id = \'#{bad_prod_id82}\' or shopify_product_id = \'#{bad_prod_id83}\' or shopify_product_id = \'#{bad_prod_id84}\' or shopify_product_id = \'#{bad_prod_id85}\' or shopify_product_id = \'#{bad_prod_id86}\' or shopify_product_id = \'#{bad_prod_id87}\' or shopify_product_id = \'#{bad_prod_id88}\' or shopify_product_id = \'#{bad_prod_id89}\' or shopify_product_id = \'#{bad_prod_id90}\' or shopify_product_id = \'#{bad_prod_id91}\' or shopify_product_id = \'#{bad_prod_id92}\' or shopify_product_id = \'#{bad_prod_id93}\' or shopify_product_id = \'#{bad_prod_id94}\' or shopify_product_id = \'#{bad_prod_id95}\' or shopify_product_id = \'#{bad_prod_id96}\' or shopify_product_id = \'#{bad_prod_id97}\' or shopify_product_id = \'#{bad_prod_id98}\' or shopify_product_id = \'#{bad_prod_id99}\' or shopify_product_id = \'#{bad_prod_id100}\' or shopify_product_id = \'#{bad_prod_id101}\' or shopify_product_id = \'#{bad_prod_id102}\' or shopify_product_id = \'#{bad_prod_id103}\' or shopify_product_id = \'#{bad_prod_id104}\' or shopify_product_id = \'#{bad_prod_id105}\' or shopify_product_id = \'#{bad_prod_id106}\' or shopify_product_id = \'#{bad_prod_id107}\' or shopify_product_id = \'#{bad_prod_id108}\' or shopify_product_id = \'#{bad_prod_id109}\' or shopify_product_id = \'#{bad_prod_id110}\' or shopify_product_id = \'#{bad_prod_id111}\' or shopify_product_id = \'#{bad_prod_id112}\' or shopify_product_id = \'#{bad_prod_id113}\' or shopify_product_id = \'#{bad_prod_id114}\' or shopify_product_id = \'#{bad_prod_id115}\' or shopify_product_id = \'#{bad_prod_id116}\' or shopify_product_id = \'#{bad_prod_id117}\' or shopify_product_id = \'#{bad_prod_id118}\' or shopify_product_id = \'#{bad_prod_id119}\' or shopify_product_id = \'#{bad_prod_id120}\' or shopify_product_id = \'#{bad_prod_id121}\' or shopify_product_id = \'#{bad_prod_id122}\' or shopify_product_id = \'#{bad_prod_id123}\' or shopify_product_id = \'#{bad_prod_id124}\' or shopify_product_id = \'#{bad_prod_id125}\' or shopify_product_id = \'#{bad_prod_id126}\' or shopify_product_id = \'#{bad_prod_id127}\' or shopify_product_id = \'#{bad_prod_id128}\' or shopify_product_id = \'#{bad_prod_id129}\' or shopify_product_id = \'#{bad_prod_id130}\' or shopify_product_id = \'#{bad_prod_id131}\' or shopify_product_id = \'#{bad_prod_id132}\' or shopify_product_id = \'#{bad_prod_id133}\' or shopify_product_id = \'#{bad_prod_id134}\' or shopify_product_id = \'#{bad_prod_id135}\' or shopify_product_id = \'#{bad_prod_id136}\' or shopify_product_id = \'#{bad_prod_id137}\' or shopify_product_id = \'#{bad_prod_id138}\' or shopify_product_id = \'#{bad_prod_id139}\' or shopify_product_id = \'#{bad_prod_id140}\' or shopify_product_id = \'#{bad_prod_id141}\' or shopify_product_id = \'#{bad_prod_id142}\' or shopify_product_id = \'#{bad_prod_id143}\' or shopify_product_id = \'#{bad_prod_id144}\' or shopify_product_id = \'#{bad_prod_id145}\' or shopify_product_id = \'#{bad_prod_id146}\' or shopify_product_id = \'#{bad_prod_id147}\' or shopify_product_id = \'#{bad_prod_id148}\' or shopify_product_id = \'#{bad_prod_id149}\' or shopify_product_id = \'#{bad_prod_id150}\' or shopify_product_id = \'#{bad_prod_id151}\' or shopify_product_id = \'#{bad_prod_id152}\' or shopify_product_id = \'#{bad_prod_id153}\' or shopify_product_id = \'#{bad_prod_id154}\' or shopify_product_id = \'#{bad_prod_id155}\' or shopify_product_id = \'#{bad_prod_id156}\' or shopify_product_id = \'#{bad_prod_id157}\' or shopify_product_id = \'#{bad_prod_id158}\' or shopify_product_id = \'#{bad_prod_id159}\' or shopify_product_id = \'#{bad_prod_id160}\' or shopify_product_id = \'#{bad_prod_id161}\' or shopify_product_id = \'#{bad_prod_id162}\' or shopify_product_id = \'#{bad_prod_id163}\' or shopify_product_id = \'#{bad_prod_id164}\' or shopify_product_id = \'#{bad_prod_id165}\' or shopify_product_id = \'#{bad_prod_id166}\' or shopify_product_id = \'#{bad_prod_id167}\' or shopify_product_id = \'#{bad_prod_id168}\' or shopify_product_id = \'#{bad_prod_id169}\' or shopify_product_id = \'#{bad_prod_id170}\' or shopify_product_id = \'#{bad_prod_id171}\' or shopify_product_id = \'#{bad_prod_id172}\' or shopify_product_id = \'#{bad_prod_id173}\' or shopify_product_id = \'#{bad_prod_id174}\' or shopify_product_id = \'#{bad_prod_id175}\' or shopify_product_id = \'#{bad_prod_id176}\' or shopify_product_id = \'#{bad_prod_id177}\' or shopify_product_id = \'#{bad_prod_id178}\' or shopify_product_id = \'#{bad_prod_id179}\' or shopify_product_id = \'#{bad_prod_id180}\' or shopify_product_id = \'#{bad_prod_id181}\' or shopify_product_id = \'#{bad_prod_id182}\' or shopify_product_id = \'#{bad_prod_id183}\')"

      staging_bad_prod_id1 = "1401707069491"
      staging_bad_prod_id2 = "1401707135027"
      staging_subs_update =  "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and (next_charge_scheduled_at > '2018-10-31' or next_charge_scheduled_at is null)  and (shopify_product_id = \'#{staging_bad_prod_id1}\' or shopify_product_id = \'#{staging_bad_prod_id2}\')"

      my_end_month = Date.today.end_of_month
      my_end_month_str = my_end_month.strftime("%Y-%m-%d")
      puts "End of the month = #{my_end_month_str}"

      straggler_subs_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and (next_charge_scheduled_at > \'#{my_end_month_str}\' and next_charge_scheduled_at is not null)  and (shopify_product_id = \'23729012754\' or shopify_product_id = \'9175678162\' or shopify_product_id = \'2209786298426\' or shopify_product_id = \'2209789771834\' or shopify_product_id = \'2267626373178\' or shopify_product_id = \'2227259342906\' or shopify_product_id = \'2267630239802\' or shopify_product_id = \'2267632697402\'  or shopify_product_id = \'2267637678138\' or shopify_product_id = \'2227252559930\' or shopify_product_id = \'2267641151546\' or shopify_product_id = \'2267641872442\' or shopify_product_id = \'2267622539322\' or shopify_product_id = \'2267625160762\' or shopify_product_id = \'2267638857786\' or shopify_product_id = \'2267639349306\' or shopify_product_id = \'1719720935482\' or shopify_product_id = \'2076495052858\' or shopify_product_id = \'2076520939578\')"

      starstruck_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and ( next_charge_scheduled_at is not null)  and (shopify_product_id = \'2294132539450\') "

      march_2019_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and (next_charge_scheduled_at > \'#{my_end_month_str}\' and next_charge_scheduled_at is not null)  and (shopify_product_id = \'2294130999354\' or shopify_product_id = \'2226391941178\' or shopify_product_id = \'2294128738362\' or shopify_product_id = \'2188532875322\' or shopify_product_id = \'2294123954234\' or shopify_product_id = \'2076495052858\' or shopify_product_id = \'2267638857786\' or shopify_product_id = \'2294131458106\'  or shopify_product_id = \'2294131458106\' or shopify_product_id = \'207131443218\' or shopify_product_id = \'2294127558714\' or shopify_product_id = \'23729012754\' or shopify_product_id = \'2209789771834\' or shopify_product_id = \'2294128738362\' or shopify_product_id = \'2076342452282\' or shopify_product_id = \'2294135029818\' or shopify_product_id = \'2294132539450\' or shopify_product_id = \'2294123954234\' or shopify_product_id = \'2188530778170\' or shopify_product_id = \'2226409963578\' or shopify_product_id = \'2209786298426\' or shopify_product_id = \'2209789771834\' or shopify_product_id = \'9175678162\' or shopify_product_id = \'2076357886010\' or shopify_product_id = \'2294132932666\' or shopify_product_id = \'2294135029818\' or shopify_product_id = \'2294132539450\' or shopify_product_id = \'2294132932666\')"

      april_2019_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and (next_charge_scheduled_at > \'#{my_end_month_str}\' and next_charge_scheduled_at is not null)  and (shopify_product_id = \'2338694234170\' or shopify_product_id = \'2339797532730\' or shopify_product_id = \'2340064526394\' or shopify_product_id = \'2340061052986\' or shopify_product_id = \'2267622539322\' or shopify_product_id = \'2339797532730\' or shopify_product_id = \'2340061577274\' or shopify_product_id = \'23729012754\'  or shopify_product_id = \'2209789771834\' or shopify_product_id = \'2339796320314\' or shopify_product_id = \'2339790127162\' or shopify_product_id = \'2267632697402\' or shopify_product_id = \'2338694856762\' or shopify_product_id = \'2267637678138\' or shopify_product_id = \'2340061052986\' or shopify_product_id = \'2338694234170\' or shopify_product_id = \'2267625160762\' or shopify_product_id = \'2209786298426\' or shopify_product_id = \'2339796320314\' or shopify_product_id = \'2339790127162\' or shopify_product_id = \'2209789771834\' or shopify_product_id = \'2267622539322\' or shopify_product_id = \'9175678162\' or shopify_product_id = \'2340063969338\' or shopify_product_id = \'2340064526394\' or shopify_product_id = \'2339789013050\' or shopify_product_id = \'2339789013050\' )"
      

      # three_months_update = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscription_id, customer_id, updated_at, next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_item_properties from subscriptions where status = 'ACTIVE' and next_charge_scheduled_at > '2018-01-31' and (shopify_product_id = \'#{monthly_box1}\' or shopify_product_id = \'#{monthly_box2}\' or shopify_product_id = \'#{monthly_box3}\' )"

      # This creates SubscriptionsUpdated records from normal subscriptions and
      # prepaid subscriptions NOT set to cancel:

      #ActiveRecord::Base.connection.execute(staging_subs_update)
      #ActiveRecord::Base.connection.execute(subs_update)
      #ActiveRecord::Base.connection.execute(alt_subs_update)
      
      ActiveRecord::Base.connection.execute(april_2019_update)
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


    def load_update_products
      UpdateProduct.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('update_products')
      # my_delete = "delete from update_products"
      # @conn.exec(my_delete)
      # my_reorder = "ALTER SEQUENCE current_products_id_seq RESTART WITH 1"
      # @conn.exec(my_reorder)
      my_insert = "insert into update_products (sku, product_title, shopify_product_id, shopify_variant_id, product_collection) values ($1, $2, $3, $4, $5)"
      @conn.prepare('statement1', "#{my_insert}")
      CSV.foreach('may2019_update_products.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
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
      CSV.foreach('may2019_current_products.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
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
