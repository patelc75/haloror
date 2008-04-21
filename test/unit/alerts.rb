require File.dirname(__FILE__) + '/../test_helper'

class AlertsTest < ActiveSupport::TestCase

  # Replace this with your real tests.
  def test_mgmt_query
    setup_email

    MgmtQuery.connection.execute("delete from device_latest_queries")
    MgmtQuery.connection.execute("delete from devices")
    MgmtQuery.connection.execute("delete from devices_users")
    MgmtQuery.connection.execute("delete from mgmt_queries")

    device = get_test_device

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

  def test_straps
    setup_email
    device = get_test_device
    
    num = Device.connection.select_value("select count(*) from device_strap_status where id = #{device.id}").to_i
    assert_equal 0, num

    event = StrapFastened.new
    event.device = device
    event.user = get_test_user
    event.timestamp = Time.now
    event.save!

    num = Device.connection.select_value("select count(*) from device_strap_status where id = #{device.id}").to_i
    assert_equal 1, num

    num = Device.connection.select_value("select count(*) from device_strap_status where is_fastened > 0 and id = #{device.id}").to_i
    assert_equal 1, num

    event = StrapRemoved.new
    event.device = device
    event.user = get_test_user
    event.timestamp = Time.now
    event.save!

    num = Device.connection.select_value("select count(*) from device_strap_status where id = #{device.id}").to_i
    assert_equal 1, num

    num = Device.connection.select_value("select count(*) from device_strap_status where is_fastened > 0 and id = #{device.id}").to_i
    assert_equal 0, num

    num = Device.connection.select_value("select count(*) from device_strap_status where is_fastened = 0 and id = #{device.id}").to_i
    assert_equal 1, num
    
  end
  
  def test_vitals
    user = get_test_user
    device = get_test_device
    setup_email

    Vital.connection.execute("delete from latest_vitals")
    Vital.connection.execute("delete from vitals")
    Vital.connection.execute("delete from device_unavailable_alerts")
    Vital.connection.execute("delete from device_available_alerts")

    Vital.job_detect_unavailable_devices
    assert_number_emails(0)

    assert_equal 0, DeviceUnavailableAlert.count(:all)
    assert_number_emails(0)
    assert_equal 1, user.devices.size
    assert_number_emails(0)

    Vital.create( :user => user, :timestamp => Time.now )
    assert_number_emails(0)
    assert_equal 1, Vital.connection.select_value('select count(*) from latest_vitals').to_i

    assert_number_emails(0)

    Vital.job_detect_unavailable_devices
    assert_number_emails(0)
  end

  private
  def assert_number_emails(num)
    assert_equal num, ActionMailer::Base.deliveries.size
  end

  def setup_email
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.delivery_method = :test
    assert_number_emails(0)
  end

  def get_test_device
    user = get_test_user

    device = Device.create(:serial_number => '0123456789', :device_type => 'test')
    device.users << user
    device.save!
    assert_equal 1, device.users.size

    device
  end

  def get_test_user
    user = User.find_by_login('test')
    user ||= User.create(:login => 'test', :email => 'test@mailinator.com', :password => '234jk234@1!d', :password_confirmation => '234jk234@1!d')
  end

  def create_and_test_mgmt_query(device, timestamp, expected_number_of_emails)
    ActionMailer::Base.deliveries = []
    MgmtQuery.create(:device_id => device.id, :timestamp_device => timestamp, :timestamp_server => timestamp)
    MgmtQuery.job_detect_disconnected_users
    assert_number_emails(expected_number_of_emails)
  end

end
