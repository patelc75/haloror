class DialUp < ActiveRecord::Base
  # ----- callbacks
  acts_as_audited

  # ----- relations
  belongs_to :user, :foreign_key => 'created_by'
  belongs_to :group # WARNING: Code cover required : https://redmine.corp.halomonitor.com/issues/2809
  has_and_belongs_to_many :gateways  
  
  # ----- validations
  validates_uniqueness_of :phone_number
  
  # ----- searches, filters, ...
  # WARNING: Code cover required : https://redmine.corp.halomonitor.com/issues/2809
  # Usage:
  #   DialUp.where_group_id                 # returns all groups
  #   DialUp.where_group_id( 1)             # just one with id == 1
  #   DialUp.where_group_id( 1, 2, 3)       # where id in (1, 2, 3)
  #   DialUp.where_group_id( [1, 2, 3])     # where id in (1, 2, 3)
  named_scope :where_group_id, lambda {|*args| { :conditions => { :group_id => (args.flatten || Group.all.collect(&:id)) } }}
  # WARNING: Code cover required : https://redmine.corp.halomonitor.com/issues/2809
  # Usage:
  #   DialUp.local
  #   DialUp.global
  ["global", "local"].each do |which|
    # include upper, lower and capitalized text-cases (GLOBAL, Global and global) in search. just in case.
    # 
    #  Tue Dec 14 00:20:15 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3859
    named_scope which.to_sym, :conditions => { :dialup_type => [which, which.upcase, which.capitalize] }, :order => "state, city, phone_number"
  end
  # WARNING: Code cover required : https://redmine.corp.halomonitor.com/issues/2809
  # Usage:
  #   DialUp.where_order_number(2)
  #   DialUp.where_order_number(2).global
  #   DialUp.local.where_order_number(2)
  named_scope :where_order_number, lambda { |*arg| { :conditions => { :order_number => arg.flatten.first.to_i } }}

  class << self #  ----------- self
    
    # WARNING: Code cover required : https://redmine.corp.halomonitor.com/issues/2809
    # Usage:
    #   DialUp.local_for_select => [["L-1234567890", "L-1234567890"]]
    #   DialUp.global_for_select => [["G-1234567890", "G-1234567890"]]
    ["global", "local"].each do |which|
      define_method "#{which}_for_select".to_sym do
        # 
        #  Tue Dec 14 00:20:23 IST 2010, ramonrails
        #   * https://redmine.corp.halomonitor.com/issues/3859
        self.send("#{which}".to_sym).collect {|e| ["#{e.state} #{e.city} #{e.phone_number}", e.phone_number] }
      end
    end
    
  end #  ----------- self
end

class DialUpNum < DialUp ; end
