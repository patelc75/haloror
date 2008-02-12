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

#class Heartrate < ActiveRecord::Base
class Heartrate < Vital
  set_table_name "heartrates"
  belongs_to :user
  
  def self.get_average(condition)
	Heartrate.average(:heartrate, :conditions => condition)
  end
  
  def self.format_average(average)
	round_to(average, 1)
  end
  
  def self.get_latest(vital)
	@series_data  = vital.map {|a| a.heartrate }
  end
end