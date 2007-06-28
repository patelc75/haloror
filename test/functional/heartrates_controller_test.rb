require File.dirname(__FILE__) + '/../test_helper'
require 'heartrates_controller'

# Re-raise errors caught by the controller.
class HeartratesController; def rescue_action(e) raise e end; end

class HeartratesControllerTest < Test::Unit::TestCase
  fixtures :heartrates

  def setup
    @controller = HeartratesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:heartrates)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_heartrate
    old_count = Heartrate.count
    post :create, :heartrate => { }
    assert_equal old_count+1, Heartrate.count
    
    assert_redirected_to heartrate_path(assigns(:heartrate))
  end

  def test_should_show_heartrate
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_heartrate
    put :update, :id => 1, :heartrate => { }
    assert_redirected_to heartrate_path(assigns(:heartrate))
  end
  
  def test_should_destroy_heartrate
    old_count = Heartrate.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Heartrate.count
    
    assert_redirected_to heartrates_path
  end
end
