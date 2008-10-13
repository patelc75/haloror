class SelfTestResultsController < RestfulAuthController
  
  def create
    begin
      request = params[:self_test_result]
      self_test_result = SelfTestResult.new
      self_test_result.result = request[:result]
      self_test_result.cmd_type = request[:cmd_type]
      self_test_result.device_id = request[:device_id]
      self_test_result.timestamp = request[:timestamp]
      self_test_item_results = request[:self_test_item_result]
      if !self_test_item_results.blank?
        if self_test_item_results.class != Array
          self_test_item_results = [self_test_item_results]
        end
        items = []
        self_test_item_results.each do |item|
          i = SelfTestItemResult.new(item)
          i.operator_id = current_user.id
          items << i
        end
        self_test_result.self_test_item_results = items
      end
      self_test_result.save!
      respond_to do |format|
        format.xml { head :ok } 
      end
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("ERROR in SelfTestResultsController:  #{e}")
      respond_to do |format|
        format.xml { head :internal_server_error }
      end
    end
  end
end