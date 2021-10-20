class SubscriptionsUpdated < ActiveRecord::Base
  self.table_name = "subscriptions_updated"
end

class CurrentProduct < ActiveRecord::Base
end

class UpdateProduct < ActiveRecord::Base
end

class BadMonthlyBox < ActiveRecord::Base
  self.table_name = "bad_monthly_box"
end

class Customer < ActiveRecord::Base
  self.table_name = 'customers'
end

class MonthlySubNull < ActiveRecord::Base
  self.table_name = 'monthly_sub_nulls'
end

class MonthlySubNullConfig < ActiveRecord::Base
  self.table_name = 'monthly_sub_nulls_config'
end

class Order < ActiveRecord::Base
  self.table_name = 'orders'
end

class SubLineItem < ActiveRecord::Base
  self.table_name = 'sub_line_items' 

end

class OrderLineItemsVariable < ActiveRecord::Base
  self.table_name = 'order_line_items_variable' 
end


class OrderLineItemsFixed < ActiveRecord::Base
  self.table_name = 'order_line_items_fixed'
  
end

class OrderCollectionSize < ActiveRecord::Base
  self.table_name = 'order_collection_sizes'
end


class FixThreeMonths < ActiveRecord::Base
  self.table_name = 'fix_three_months'
end   

class BadRecurringSub < ActiveRecord::Base
  self.table_name = 'bad_recurring_subs'
end

class ToughLuxeSub < ActiveRecord::Base
  self.table_name = 'tough_luxe_subs'
end

class Subscription < ActiveRecord::Base
  self.table_name = 'subscriptions'
end

class SubCollectionSizes < ActiveRecord::Base
  self.table_name = 'sub_collection_sizes'
end

class SubsUpdatedInventorySize < ActiveRecord::Base
  self.table_name = 'subs_updated_inventory_sizes'
end