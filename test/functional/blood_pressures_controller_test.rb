require File.dirname(__FILE__) + '/../test_helper'
require 'blood_pressures_controller'

# Re-raise errors caught by the controller.
class BloodPressuresController; def rescue_action(e) raise e end; end

class BloodPressuresControllerTest < Test::Unit::TestCase
  fixtures :blood_pressures

  def setup
    @controller = BloodPressuresController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:blood_pressures)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_blood_pressure
    old_count = BloodPressure.count
    post :create, :blood_pressure => { }
    assert_equal old_count + 1, BloodPressure.count

    assert_redirected_to blood_pressure_path(assigns(:blood_pressure))
  end

  def test_should_show_blood_pressure
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_blood_pressure
    put :update, :id => 1, :blood_pressure => { }
    assert_redirected_to blood_pressure_path(assigns(:blood_pressure))
  end

  def test_should_destroy_blood_pressure
    old_count = BloodPressure.count
    delete :destroy, :id => 1
    assert_equal old_count-1, BloodPressure.count

    assert_redirected_to blood_pressures_path
  end
end
