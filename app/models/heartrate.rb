# == Schema Information
# Schema version: 2
#
# Table name: heartrates
#
#  id        :integer       not null, primary key
#  user_id   :integer       
#  timestamp :datetime      
#  heartrate :integer       not null
#

require 'active_record'

class Heartrate < ActiveRecord::Base
end