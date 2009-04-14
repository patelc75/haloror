class TimeZonesController < RestfulAuthController
  include UtilityHelper
  
  def create
    user_id = params[:gateway][:user_id]
    if !user_id.blank?
      user = User.find(user_id)
      if user
        offset = UtilityHelper.offset_for_time_zone(user)
      end
    end
    if offset
      xml = get_offset_xml(offset)
      respond_to do |format|
        format.xml {render :xml => xml}
      end
    else
      render :status => 500
    end
  end
  
  def get_offset_xml(offset)
    return "<time_zone><offset>#{offset}</offset></time_zone>"
  end
end