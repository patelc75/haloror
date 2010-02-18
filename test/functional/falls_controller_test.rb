# require File.dirname(__FILE__) + '/../test_helper'
# require 'falls_controller'
# 
# # Re-raise errors caught by the controller.
# class FallsController; def rescue_action(e) raise e end; end
# 
# class FallsControllerTest < Test::Unit::TestCase
#   fixtures :falls
# 
#   def setup
#     @controller = FallsController.new
#     @request    = ActionController::TestRequest.new
#     @response   = ActionController::TestResponse.new
#   end
# 
#   def test_should_get_index
#     get :index
#     assert_response :success
#     assert assigns(:falls)
#   end
# 
#   def test_should_get_new
#     get :new
#     assert_response :success
#   end
#   
#   def test_should_create_fall
#     old_count = Fall.count
#     post :create, :fall => { }
#     assert_equal old_count+1, Fall.count
#     
#     assert_redirected_to fall_path(assigns(:fall))
#   end
# 
#   def test_should_show_fall
#     get :show, :id => 1
#     assert_response :success
#   end
# 
#   def test_should_get_edit
#     get :edit, :id => 1
#     assert_response :success
#   end
#   
#   def test_should_update_fall
#     put :update, :id => 1, :fall => { }
#     assert_redirected_to fall_path(assigns(:fall))
#   end
#   
#   def test_should_destroy_fall
#     old_count = Fall.count
#     delete :destroy, :id => 1
#     assert_equal old_count-1, Fall.count
#     
#     assert_redirected_to falls_path
#   end
# end
