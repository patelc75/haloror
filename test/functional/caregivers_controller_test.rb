require File.dirname(__FILE__) + '/../test_helper'
require 'caregivers_controller'

# Re-raise errors caught by the controller.
class CaregiversController; def rescue_action(e) raise e end; end

class CaregiversControllerTest < Test::Unit::TestCase
  fixtures :caregivers

  def setup
    @controller = CaregiversController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:caregivers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_caregiver
    old_count = Caregiver.count
    post :create, :caregiver => { }
    assert_equal old_count+1, Caregiver.count
    
    assert_redirected_to caregiver_path(assigns(:caregiver))
  end

  def test_should_show_caregiver
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_caregiver
    put :update, :id => 1, :caregiver => { }
    assert_redirected_to caregiver_path(assigns(:caregiver))
  end
  
  def test_should_destroy_caregiver
    old_count = Caregiver.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Caregiver.count
    
    assert_redirected_to caregivers_path
  end
end
