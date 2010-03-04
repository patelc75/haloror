class DialUpLastSuccessful < ActiveRecord::Base
  # filters, scopes
  #
  # dynamically generated named scope
  #  by_dialup_type([...]), by_device_id([...]), ...
  # To degine more similar scopes, just add the column name symbl to the array
  [:device_id].each do |which|
    named_scope "by_#{which}".to_sym, lambda { |*args|
      var = (args.blank? ? nil : args.flatten.first)
      { :conditions => (var.blank? ? {} : {which => var}) }
    }    
  end
end
