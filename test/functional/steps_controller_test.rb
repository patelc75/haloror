# require File.dirname(__FILE__) + '/../test_helper'
# require 'steps_controller'
# 
# # Re-raise errors caught by the controller.
# class StepsController; def rescue_action(e) raise e end; end
# 
# class StepsControllerTest < Test::Unit::TestCase
#   fixtures :steps
# 
#   def setup
#     @controller = StepsController.new
#     @request    = ActionController::TestRequest.new
#     @response   = ActionController::TestResponse.new
#   end
# 
#   def test_should_get_index
#     get :index
#     assert_response :success
#     assert assigns(:steps)
#   end
# 
#   def test_should_get_new
#     get :new
#     assert_response :success
#   end
#   
#   def test_should_create_step
#     old_count = Step.count
#     post :create, :step => { }
#     assert_equal old_count+1, Step.count
#     
#     assert_redirected_to step_path(assigns(:step))
#   end
# 
#   def test_should_show_step
#     get :show, :id => 1
#     assert_response :success
#   end
# 
#   def test_should_get_edit
#     get :edit, :id => 1
#     assert_response :success
#   end
#   
#   def test_should_update_step
#     put :update, :id => 1, :step => { }
#     assert_redirected_to step_path(assigns(:step))
#   end
#   
#   def test_should_destroy_step
#     old_count = Step.count
#     delete :destroy, :id => 1
#     assert_equal old_count-1, Step.count
#     
#     assert_redirected_to steps_path
#   end
# end
