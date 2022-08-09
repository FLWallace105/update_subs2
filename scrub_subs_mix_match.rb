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

    end



    puts "All done scrubbing Mix and Match!"
  end

end