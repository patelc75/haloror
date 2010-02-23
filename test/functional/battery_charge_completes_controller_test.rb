# require File.dirname(__FILE__) + '/../test_helper'
# 
# class BatteryChargeCompletesControllerTest < ActionController::TestCase
#   def test_should_get_index
#     get :index
#     assert_response :success
#     assert_not_nil assigns(:battery_charge_completes)
#   end
# 
#   def test_should_get_new
#     get :new
#     assert_response :success
#   end
# 
#   def test_should_create_battery_charge_complete
#     assert_difference('BatteryChargeComplete.count') do
#       post :create, :battery_charge_complete => { }
#     end
# 
#     assert_redirected_to battery_charge_complete_path(assigns(:battery_charge_complete))
#   end
# 
#   def test_should_show_battery_charge_complete
#     get :show, :id => battery_charge_completes(:one).id
#     assert_response :success
#   end
# 
#   def test_should_get_edit
#     get :edit, :id => battery_charge_completes(:one).id
#     assert_response :success
#   end
# 
#   def test_should_update_battery_charge_complete
#     put :update, :id => battery_charge_completes(:one).id, :battery_charge_complete => { }
#     assert_redirected_to battery_charge_complete_path(assigns(:battery_charge_complete))
#   end
# 
#   def test_should_destroy_battery_charge_complete
#     assert_difference('BatteryChargeComplete.count', -1) do
#       delete :destroy, :id => battery_charge_completes(:one).id
#     end
# 
#     assert_redirected_to battery_charge_completes_path
#   end
# end
