
Then /^the last invoice (should|should not) have (.+) columns (empty|filled)$/ do |_condition, _cols, _state|
  (invoice = Invoice.last).should_not be_blank
  _cols.split(',').collect {|e| e.strip.to_sym}.each do |_column|
    if _condition == 'should'
      if _state == 'empty'
        invoice.send( _column).should be_blank
      else
        invoice.send( _column).should_not be_blank
      end
    else
      if _state == 'empty'
        invoice.send( _column).should_not be_blank
      else
        invoice.send( _column).should be_blank
      end
    end
  end
end
