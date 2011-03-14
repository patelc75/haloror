require 'test_helper'

class ShippingOptionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:shipping_options)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_shipping_option
    assert_difference('ShippingOption.count') do
      post :create, :shipping_option => { }
    end

    assert_redirected_to shipping_option_path(assigns(:shipping_option))
  end

  def test_should_show_shipping_option
    get :show, :id => shipping_options(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => shipping_options(:one).id
    assert_response :success
  end

  def test_should_update_shipping_option
    put :update, :id => shipping_options(:one).id, :shipping_option => { }
    assert_redirected_to shipping_option_path(assigns(:shipping_option))
  end

  def test_should_destroy_shipping_option
    assert_difference('ShippingOption.count', -1) do
      delete :destroy, :id => shipping_options(:one).id
    end

    assert_redirected_to shipping_options_path
  end
end
