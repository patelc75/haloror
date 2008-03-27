xml.chart do
  xml.live_update( :url=> url_for( :controller => 'chart', :action => 'refresh_data', :id => @user.id),
                   :delay => 5 )
  xml.chart_data do
    xml.row do
      xml.null
      @categories.each do |c|
        xml.string( c )
      end
    end
    xml.row do
      xml.string( "Heartrate" )      
      @heartrate_series.each do |c|
        c.is_a?(String) ? xml.string( c ) : xml.number( c )
      end
    end      
    xml.row do
      xml.string( "Skin Temperature" )      
      @skintemp_series.each do |c|
        c.is_a?(String) ? xml.string( c ) : xml.number( c )
      end
    end
  end
  
  xml.chart_value_text do
    xml.row do
      xml.null
      @categories.each do |c|
        xml.string(  )
      end
    end
    xml.row do
      xml.null()
      @heartrate_labels.each do |c|
        c.is_a?(String) ? xml.string( c ) : xml.number( c )
      end
    end      
    xml.row do
      xml.null()
      @skintemp_labels.each do |c|
        c.is_a?(String) ? xml.string( c ) : xml.number( c )
      end
    end
  end
end    