require File.dirname(__FILE__) + '/../test_helper'
require 'call_list_controller'

# Re-raise errors caught by the controller.
class CallListController; def rescue_action(e) raise e end; end

class CallListControllerTest < Test::Unit::TestCase
  def setup
    @controller = CallListController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
