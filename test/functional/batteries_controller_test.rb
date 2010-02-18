# require File.dirname(__FILE__) + '/../test_helper'
# require 'batteries_controller'
# 
# # Re-raise errors caught by the controller.
# class BatteriesController; def rescue_action(e) raise e end; end
# 
# class BatteriesControllerTest < Test::Unit::TestCase
#   fixtures :batteries
# 
#   def setup
#     @controller = BatteriesController.new
#     @request    = ActionController::TestRequest.new
#     @response   = ActionController::TestResponse.new
#   end
# 
#   def test_should_get_index
#     get :index
#     assert_response :success
#     assert assigns(:batteries)
#   end
# 
#   def test_should_get_new
#     get :new
#     assert_response :success
#   end
#   
#   def test_should_create_battery
#     old_count = Battery.count
#     post :create, :battery => { }
#     assert_equal old_count+1, Battery.count
#     
#     assert_redirected_to battery_path(assigns(:battery))
#   end
# 
#   def test_should_show_battery
#     get :show, :id => 1
#     assert_response :success
#   end
# 
#   def test_should_get_edit
#     get :edit, :id => 1
#     assert_response :success
#   end
#   
#   def test_should_update_battery
#     put :update, :id => 1, :battery => { }
#     assert_redirected_to battery_path(assigns(:battery))
#   end
#   
#   def test_should_destroy_battery
#     old_count = Battery.count
#     delete :destroy, :id => 1
#     assert_equal old_count-1, Battery.count
#     
#     assert_redirected_to batteries_path
#   end
# end
