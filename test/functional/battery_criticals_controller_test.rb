# require File.dirname(__FILE__) + '/../test_helper'
# 
# class BatteryCriticalsControllerTest < ActionController::TestCase
#   def test_should_get_index
#     get :index
#     assert_response :success
#     assert_not_nil assigns(:battery_criticals)
#   end
# 
#   def test_should_get_new
#     get :new
#     assert_response :success
#   end
# 
#   def test_should_create_battery_critical
#     assert_difference('BatteryCritical.count') do
#       post :create, :battery_critical => { }
#     end
# 
#     assert_redirected_to battery_critical_path(assigns(:battery_critical))
#   end
# 
#   def test_should_show_battery_critical
#     get :show, :id => battery_criticals(:one).id
#     assert_response :success
#   end
# 
#   def test_should_get_edit
#     get :edit, :id => battery_criticals(:one).id
#     assert_response :success
#   end
# 
#   def test_should_update_battery_critical
#     put :update, :id => battery_criticals(:one).id, :battery_critical => { }
#     assert_redirected_to battery_critical_path(assigns(:battery_critical))
#   end
# 
#   def test_should_destroy_battery_critical
#     assert_difference('BatteryCritical.count', -1) do
#       delete :destroy, :id => battery_criticals(:one).id
#     end
# 
#     assert_redirected_to battery_criticals_path
#   end
# end
