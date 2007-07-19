require File.dirname(__FILE__) + '/../test_helper'
require 'chart_controller'

# Re-raise errors caught by the controller.
class ChartController; def rescue_action(e) raise e end; end

class ChartControllerTest < Test::Unit::TestCase
  def setup
    @controller = ChartController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
