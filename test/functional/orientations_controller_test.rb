require File.dirname(__FILE__) + '/../test_helper'
require 'orientations_controller'

# Re-raise errors caught by the controller.
class OrientationsController; def rescue_action(e) raise e end; end

class OrientationsControllerTest < Test::Unit::TestCase
  fixtures :orientations

  def setup
    @controller = OrientationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:orientations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_orientation
    old_count = Orientation.count
    post :create, :orientation => { }
    assert_equal old_count+1, Orientation.count
    
    assert_redirected_to orientation_path(assigns(:orientation))
  end

  def test_should_show_orientation
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_orientation
    put :update, :id => 1, :orientation => { }
    assert_redirected_to orientation_path(assigns(:orientation))
  end
  
  def test_should_destroy_orientation
    old_count = Orientation.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Orientation.count
    
    assert_redirected_to orientations_path
  end
end
