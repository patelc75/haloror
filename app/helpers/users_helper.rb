module UsersHelper

  # alert button tag
  def alert_button(type = "normal")
    type = "normal" unless ["normal", "caution", "abnormal"].include?(type) # only these types allowed
    "<a href='#' class='button_new_dash_2 #{type} small'><strong>#{type.upcase}</strong></a>"
  end
end