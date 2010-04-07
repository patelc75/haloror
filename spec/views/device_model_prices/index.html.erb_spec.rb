require 'spec_helper'

describe "/device_model_prices/index.html.erb" do
  include DeviceModelPricesHelper

  before(:each) do
    assigns[:device_model_prices] = [
      stub_model(DeviceModelPrice,
        :device_model => 1,
        :coupon_code => "value for coupon_code",
        :deposit => 1,
        :shipping => 1,
        :monthly_recurring => 1,
        :months_advance => 1,
        :months_trial => 1
      ),
      stub_model(DeviceModelPrice,
        :device_model => 1,
        :coupon_code => "value for coupon_code",
        :deposit => 1,
        :shipping => 1,
        :monthly_recurring => 1,
        :months_advance => 1,
        :months_trial => 1
      )
    ]
  end

  it "renders a list of device_model_prices" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for coupon_code".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
