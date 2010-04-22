require File.dirname(__FILE__) + '/../spec_helper'

describe MgmtQuery do  
  # before(:all) do
  #   mgmt_cmd = MgmtCmd.new_initialize('firmware_upgrade')
  #   setup_model(mgmt_cmd)
  #   puts mgmt_cmd.inspect
  #   mgmt_cmd.save!
  #   
  #   mgmt_query = MgmtQuery.new_initialize()
  #   curl_cmd = get_curl_cmd(mgmt_query)
  #   server_response = `#{curl_cmd}`
  #   server_hash = Hash.from_xml(server_response)
  #   if server_hash["management_cmd_server"]
  #     if server_hash["management_cmd_server"]["cmd_type"] == 'firmware_upgrade'
  #       curl_cmd = get_curl_cmd_for_ack(MgmtAck.new, 'firmware_upgrade')
  #       server_response = `#{curl_cmd}`
  #     end
  #   end
  #   
  #   
  #   mgmt_cmd = MgmtCmd.new_initialize('info')
  #   setup_model(mgmt_cmd)
  #   mgmt_cmd.save!       
  #   
  #   mgmt_query = MgmtQuery.new_initialize()
  #   curl_cmd = get_curl_cmd(mgmt_query)
  #   server_response = `#{curl_cmd}`
  #   puts "************************"
  #   puts server_response
  #   server_hash = Hash.from_xml(server_response)
  #   if server_hash["management_cmd_server"]
  #     if server_hash["management_cmd_server"]["cmd_type"] == 'info'
  #       curl_cmd = get_curl_cmd_for_ack(MgmtAck.new, 'info')
  #       server_response = `#{curl_cmd}`
  #     end
  #   end
  # end
  
  it "should have one more of each model" do
    #    num_records = 0
    #    CLAZZES.each do |clazz|
    #      num_records += clazz.count
    #    end
    #    num_records.should be(@no_records + CLAZZES.size)
  end
end
