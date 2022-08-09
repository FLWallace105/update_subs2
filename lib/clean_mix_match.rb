#clean_mix_match.rb
class CleanMixMatch
    VALID_PROPS = ["leggings", "tops", "sports-jacket", "sports-bra", "gloves", "product_collection", "real_email", "unique_identifier"]


    def self.cleanup_mix_match_props(my_json)
        
        puts "Received properties #{my_json.inspect}"

        my_json.delete_if {|x| !VALID_PROPS.include?(x['name']) }

        return my_json

    end


end