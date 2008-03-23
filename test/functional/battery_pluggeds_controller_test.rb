require File.dirname(__FILE__) + '/../test_helper'

class BatteryPluggedsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:battery_pluggeds)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_battery_plugged
    assert_difference('BatteryPlugged.count') do
      post :create, :battery_plugged => { }
    end

    assert_redirected_to battery_plugged_path(assigns(:battery_plugged))
  end

  def test_should_show_battery_plugged
    get :show, :id => battery_pluggeds(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => battery_pluggeds(:one).id
    assert_response :success
  end

  def test_should_update_battery_plugged
    put :update, :id => battery_pluggeds(:one).id, :battery_plugged => { }
    assert_redirected_to battery_plugged_path(assigns(:battery_plugged))
  end

  def test_should_destroy_battery_plugged
    assert_difference('BatteryPlugged.count', -1) do
      delete :destroy, :id => battery_pluggeds(:one).id
    end

    assert_redirected_to battery_pluggeds_path
  end
end
