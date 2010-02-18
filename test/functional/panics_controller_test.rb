# require File.dirname(__FILE__) + '/../test_helper'
# require 'panics_controller'
# 
# # Re-raise errors caught by the controller.
# class PanicsController; def rescue_action(e) raise e end; end
# 
# class PanicsControllerTest < Test::Unit::TestCase
#   fixtures :panics
# 
#   def setup
#     @controller = PanicsController.new
#     @request    = ActionController::TestRequest.new
#     @response   = ActionController::TestResponse.new
#   end
# 
#   def test_should_get_index
#     get :index
#     assert_response :success
#     assert assigns(:panics)
#   end
# 
#   def test_should_get_new
#     get :new
#     assert_response :success
#   end
#   
#   def test_should_create_panic
#     old_count = Panic.count
#     post :create, :panic => { }
#     assert_equal old_count+1, Panic.count
#     
#     assert_redirected_to panic_path(assigns(:panic))
#   end
# 
#   def test_should_show_panic
#     get :show, :id => 1
#     assert_response :success
#   end
# 
#   def test_should_get_edit
#     get :edit, :id => 1
#     assert_response :success
#   end
#   
#   def test_should_update_panic
#     put :update, :id => 1, :panic => { }
#     assert_redirected_to panic_path(assigns(:panic))
#   end
#   
#   def test_should_destroy_panic
#     old_count = Panic.count
#     delete :destroy, :id => 1
#     assert_equal old_count-1, Panic.count
#     
#     assert_redirected_to panics_path
#   end
# end
