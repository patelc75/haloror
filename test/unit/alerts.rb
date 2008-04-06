require File.dirname(__FILE__) + '/../test_helper'

class AlertsTest < ActiveSupport::TestCase

  # Replace this with your real tests.
  def test_mgmt_query
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.delivery_method = :test
    assert_equal 0, ActionMailer::Base.deliveries.size

    MgmtQuery.connection.execute("delete from device_latest_queries")
    MgmtQuery.connection.execute("delete from devices")
    MgmtQuery.connection.execute("delete from devices_users")
    MgmtQuery.connection.execute("delete from mgmt_queries")

    user = User.find_by_login('test')
    user ||= User.create(:login => 'test', :email => 'test@mailinator.com', :password => '234jk234@1!d', :password_confirmation => '234jk234@1!d')
    device = Device.create(:serial_number => '0123456789', :device_type => 'test')
    device.users << user
    device.save!
    assert_equal 1, device.users.size

    1.upto(10) do
      create_and_test_mgmt_query(device, Time.now, 0)
    end

    assert_equal 1, MgmtQuery.connection.select_value("select count(*) from device_latest_queries").to_i

    yesterday = 1.days.ago
    1.upto(GatewayOfflineAlert::MAX_ATTEMPTS_BEFORE_NOTIFICATION - 1) do
      create_and_test_mgmt_query(device, yesterday, 0)
    end
    assert_equal yesterday.to_s, Time.parse(MgmtQuery.connection.select_value("select updated_at from device_latest_queries")).to_s

    create_and_test_mgmt_query(device, yesterday, 1)
  end

  def test_vitals
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.delivery_method = :test

    assert_equal 0, ActionMailer::Base.deliveries.size
    Vital.job_detect_unavailable_devices
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  private
  def create_and_test_mgmt_query(device, timestamp, expected_number_of_emails)
    ActionMailer::Base.deliveries = []
    MgmtQuery.create(:device_id => device.id, :timestamp_device => timestamp, :timestamp_server => timestamp)
    MgmtQuery.job_detect_disconnected_users
    assert_equal expected_number_of_emails, ActionMailer::Base.deliveries.size
  end

end
