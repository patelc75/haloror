require File.dirname(__FILE__) + '/../spec_helper'

describe Fall do
  
  before(:all) do
    @no_records = Fall.count
    fall = Fall.new
    curl_cmd = get_curl_cmd(fall)
    `#{curl_cmd}`
  end

  it "should have one more fall" do
    Fall.should have(@no_records + 1).records
  end

end

