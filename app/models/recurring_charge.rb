class RecurringCharge < ActiveRecord::Base
	belongs_to :group
	
	def group_charge
		if self.charge != nil or self.charge != '' 
			charge = self.charge
		else
			charge = AUTH_NET_SUBSCRIPTION_BILL_AMOUNT_PER_INTERVAL
		end
		charge
	end
end
