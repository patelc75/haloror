require File.dirname(__FILE__) + '/../test_helper'

class StrapFastenedsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:strap_fasteneds)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_strap_fastened
    assert_difference('StrapFastened.count') do
      post :create, :strap_fastened => { }
    end

    assert_redirected_to strap_fastened_path(assigns(:strap_fastened))
  end

  def test_should_show_strap_fastened
    get :show, :id => strap_fasteneds(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => strap_fasteneds(:one).id
    assert_response :success
  end

  def test_should_update_strap_fastened
    put :update, :id => strap_fasteneds(:one).id, :strap_fastened => { }
    assert_redirected_to strap_fastened_path(assigns(:strap_fastened))
  end

  def test_should_destroy_strap_fastened
    assert_difference('StrapFastened.count', -1) do
      delete :destroy, :id => strap_fasteneds(:one).id
    end

    assert_redirected_to strap_fasteneds_path
  end
end
