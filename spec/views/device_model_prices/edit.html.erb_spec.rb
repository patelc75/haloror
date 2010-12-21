require File.join(File.dirname(__FILE__), "..", "..", "spec_helper")

describe "/device_model_prices/edit.html.erb" do
  include DeviceModelPricesHelper

  before(:each) do
    assigns[:device_model_price] = @device_model_price = stub_model(DeviceModelPrice,
      :new_record? => false,
      :device_model => 1,
      :coupon_code => "value for coupon_code",
      :deposit => 1,
      :shipping => 1,
      :monthly_recurring => 1,
      :months_advance => 1,
      :months_trial => 1
    )
  end

  # it "renders the edit device_model_price form" do
  #   render
  # 
  #   response.should have_tag("form[action=#{device_model_price_path(@device_model_price)}][method=post]") do
  #     with_tag('input#device_model_price_device_model[name=?]', "device_model_price[device_model]")
  #     with_tag('input#device_model_price_coupon_code[name=?]', "device_model_price[coupon_code]")
  #     with_tag('input#device_model_price_deposit[name=?]', "device_model_price[deposit]")
  #     with_tag('input#device_model_price_shipping[name=?]', "device_model_price[shipping]")
  #     with_tag('input#device_model_price_monthly_recurring[name=?]', "device_model_price[monthly_recurring]")
  #     with_tag('input#device_model_price_months_advance[name=?]', "device_model_price[months_advance]")
  #     with_tag('input#device_model_price_months_trial[name=?]', "device_model_price[months_trial]")
  #   end
  # end
end
