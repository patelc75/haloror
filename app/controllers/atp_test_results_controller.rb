class AtpTestResultsController < ApplicationController
  
  def index
    begin
      request = params[:atp_test_result]
      atp_test_result = AtpTestResult.new
      atp_test_result.result = request[:result]
      atp_test_result.operator_id = current_user.id
      atp_test_result.created_by = current_user.id
      atp_test_result.comments = request[:comments]
      atp_test_result.device_id = request[:device_id]
      atp_test_result.timestamp = request[:timestamp]
      atp_item_results = request[:atp_item_result]
      if !atp_item_results.blank?
        if atp_item_results.class != Array
          atp_item_results = [atp_item_results]
        end
        items = []
        atp_item_results.each do |item|
          i = AtpItemResult.new(item)
          i.operator_id = current_user.id
          i.created_by = current_user.id
          items << i
        end
        atp_test_result.atp_item_results = items
      end
      atp_test_result.save!
      respond_to do |format|
        format.xml { head :ok } 
      end
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("ERROR in AtpTestResultsController:  #{e}")
      respond_to do |format|
        format.xml { head :internal_server_error }
      end
    end
  end
end