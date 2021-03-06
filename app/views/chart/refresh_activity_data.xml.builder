xml.chart do
  xml.live_update( :url=> url_for( :controller => 'chart', :action => 'refresh_activity_data', :id => @user.id),
                   :delay => 5 )
  xml.chart_data do
    xml.row do
      xml.null
      @categories.each do |c|
        xml.string( c )
      end
    end      
    xml.row do
      xml.string( "Activity" )      
      @activity_series.each do |c|
        c.is_a?(String) ? xml.string( c ) : xml.number( c )
      end
    end
  end
end