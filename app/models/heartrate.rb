# == Schema Information
# Schema version: 1
#
# Table name: heartrates
#
#  id        :integer(11)   not null, primary key
#  sessionID :integer(11)   
#  timeStamp :integer(11)   
#  heartRate :integer(11)   
#

class Heartrate < ActiveRecord::Base
end
