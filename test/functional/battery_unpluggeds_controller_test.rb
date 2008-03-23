require File.dirname(__FILE__) + '/../test_helper'

class BatteryUnpluggedsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:battery_unpluggeds)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_battery_unplugged
    assert_difference('BatteryUnplugged.count') do
      post :create, :battery_unplugged => { }
    end

    assert_redirected_to battery_unplugged_path(assigns(:battery_unplugged))
  end

  def test_should_show_battery_unplugged
    get :show, :id => battery_unpluggeds(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => battery_unpluggeds(:one).id
    assert_response :success
  end

  def test_should_update_battery_unplugged
    put :update, :id => battery_unpluggeds(:one).id, :battery_unplugged => { }
    assert_redirected_to battery_unplugged_path(assigns(:battery_unplugged))
  end

  def test_should_destroy_battery_unplugged
    assert_difference('BatteryUnplugged.count', -1) do
      delete :destroy, :id => battery_unpluggeds(:one).id
    end

    assert_redirected_to battery_unpluggeds_path
  end
end
