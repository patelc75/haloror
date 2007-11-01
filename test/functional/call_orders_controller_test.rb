require File.dirname(__FILE__) + '/../test_helper'
require 'call_orders_controller'

# Re-raise errors caught by the controller.
class CallOrdersController; def rescue_action(e) raise e end; end

class CallOrdersControllerTest < Test::Unit::TestCase
  fixtures :call_orders

  def setup
    @controller = CallOrdersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:call_orders)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_call_order
    old_count = CallOrder.count
    post :create, :call_order => { }
    assert_equal old_count+1, CallOrder.count
    
    assert_redirected_to call_order_path(assigns(:call_order))
  end

  def test_should_show_call_order
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_call_order
    put :update, :id => 1, :call_order => { }
    assert_redirected_to call_order_path(assigns(:call_order))
  end
  
  def test_should_destroy_call_order
    old_count = CallOrder.count
    delete :destroy, :id => 1
    assert_equal old_count-1, CallOrder.count
    
    assert_redirected_to call_orders_path
  end
end
