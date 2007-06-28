require File.dirname(__FILE__) + '/../test_helper'
require 'raw_data_files_controller'

# Re-raise errors caught by the controller.
class RawDataFilesController; def rescue_action(e) raise e end; end

class RawDataFilesControllerTest < Test::Unit::TestCase
  fixtures :raw_data_files

  def setup
    @controller = RawDataFilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:raw_data_files)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_raw_data_file
    old_count = RawDataFile.count
    post :create, :raw_data_file => { }
    assert_equal old_count+1, RawDataFile.count
    
    assert_redirected_to raw_data_file_path(assigns(:raw_data_file))
  end

  def test_should_show_raw_data_file
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_raw_data_file
    put :update, :id => 1, :raw_data_file => { }
    assert_redirected_to raw_data_file_path(assigns(:raw_data_file))
  end
  
  def test_should_destroy_raw_data_file
    old_count = RawDataFile.count
    delete :destroy, :id => 1
    assert_equal old_count-1, RawDataFile.count
    
    assert_redirected_to raw_data_files_path
  end
end
