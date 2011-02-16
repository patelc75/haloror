require 'test_helper'

class InvoiceNotesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:invoice_notes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_invoice_note
    assert_difference('InvoiceNote.count') do
      post :create, :invoice_note => { }
    end

    assert_redirected_to invoice_note_path(assigns(:invoice_note))
  end

  def test_should_show_invoice_note
    get :show, :id => invoice_notes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => invoice_notes(:one).id
    assert_response :success
  end

  def test_should_update_invoice_note
    put :update, :id => invoice_notes(:one).id, :invoice_note => { }
    assert_redirected_to invoice_note_path(assigns(:invoice_note))
  end

  def test_should_destroy_invoice_note
    assert_difference('InvoiceNote.count', -1) do
      delete :destroy, :id => invoice_notes(:one).id
    end

    assert_redirected_to invoice_notes_path
  end
end
