
Then /^the last invoice has pro\-rata and recurring columns (empty|filled)$/ do |_state|
  (invoice = Invoice.last).should_not be_blank
  [:prorate_start_date, :recurring_start_date, :prorate, :recurring].each do |_column|
    if _state == 'empty'
      invoice.send( _column).should be_blank
    else
      invoice.send( _column).should_not be_blank
    end
  end
end
