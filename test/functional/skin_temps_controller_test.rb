# require File.dirname(__FILE__) + '/../test_helper'
# require 'skin_temps_controller'
# 
# # Re-raise errors caught by the controller.
# class SkinTempsController; def rescue_action(e) raise e end; end
# 
# class SkinTempsControllerTest < Test::Unit::TestCase
#   fixtures :skin_temps
# 
#   def setup
#     @controller = SkinTempsController.new
#     @request    = ActionController::TestRequest.new
#     @response   = ActionController::TestResponse.new
#   end
# 
#   def test_should_get_index
#     get :index
#     assert_response :success
#     assert assigns(:skin_temps)
#   end
# 
#   def test_should_get_new
#     get :new
#     assert_response :success
#   end
#   
#   def test_should_create_skin_temp
#     old_count = SkinTemp.count
#     post :create, :skin_temp => { }
#     assert_equal old_count+1, SkinTemp.count
#     
#     assert_redirected_to skin_temp_path(assigns(:skin_temp))
#   end
# 
#   def test_should_show_skin_temp
#     get :show, :id => 1
#     assert_response :success
#   end
# 
#   def test_should_get_edit
#     get :edit, :id => 1
#     assert_response :success
#   end
#   
#   def test_should_update_skin_temp
#     put :update, :id => 1, :skin_temp => { }
#     assert_redirected_to skin_temp_path(assigns(:skin_temp))
#   end
#   
#   def test_should_destroy_skin_temp
#     old_count = SkinTemp.count
#     delete :destroy, :id => 1
#     assert_equal old_count-1, SkinTemp.count
#     
#     assert_redirected_to skin_temps_path
#   end
# end
