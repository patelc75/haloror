class Rma < ActiveRecord::Base
  has_many :atp_test_results, :through => :atp_test_results_rmas
  has_many :rma_items
  belongs_to :group
  belongs_to :user
  validates_presence_of :serial_number
  
  # WARNING: test cover required
  # Usage:
  #   user_id_like 123
  #   user_id_like 123, 456
  #     useful to get values from user input forms and put directly into named scope
  #   user_id_like "123"
  #   user_id_like "123, 456"
  named_scope :user_id_like, lambda {|*args|
    args = args.flatten if args.is_a?( Array)
    options = if args.blank?
      {}
    elsif args.is_a?( Array)
      args.flatten.collect(&:to_i)
    elsif args.is_a?( String)
      ids = args.split(',').collect(&:to_i).compact.uniq.reject(&:zero?) # all comma separated ids as integer array
      ids.blank? ? {} : ids # no integer ids collected? just ignore search
    elsif args.is_a?( Fixnum)
      args.to_i
    end
    { :conditions => { :user_id => options }}
  }
  
  # WARNING: test cover required
  # Usage:
  #   user_like       # works similar to "all"
  #   user_like 'am'
  #   user_like 'Carter'
  #   user_like 'Carter, itt, drew'
  # same for other methods...
  #   serial_number_like ...
  #   status_like ...
  # console output of this usage
  # # >> Rma.serial_number_like("12").collect(&:serial_number)
  # #   Rma Load (0.006221)   SELECT * FROM "rmas" WHERE (serial_number LIKE E'%12%') 
  # #   User Load (0.004867)   SELECT * FROM "users" WHERE ("users".id IN (E'123')) 
  # # => ["1234567890"]
  # # >> Rma.serial_number_like("12, 11").collect(&:serial_number)
  # #   Rma Load (0.044509)   SELECT * FROM "rmas" WHERE (serial_number LIKE E'%12%' OR serial_number LIKE E'%11%') 
  # #   User Load (0.005352)   SELECT * FROM "users" WHERE ("users".id IN (E'111',E'123')) 
  # # => ["1234567890", "1111111", "1111111"]
  ["user", "serial_number", "status"].each do |which|
    named_scope :"#{which}_like", lambda { |*args|
      substitute = {"user" => "users.name"}
      if args.blank?
        options = {} # just like "all"
      else
        # collect comma separated uniq values in array
        phrases = (args.flatten.first || '').split(',').collect(&:strip).compact.uniq
        # console outputof the expression statement below
        # => ["an", "bc", "fr", "gt"]
        # >> [ phrases.length.times.collect {|e| "users.name LIKE ?" }.join(" OR ") ] + phrases.collect {|e| "%#{e}%" }
        # => ["users.name LIKE ? OR users.name LIKE ? OR users.name LIKE ? OR users.name LIKE ?", "%an%", "%bc%", "%fr%", "%gt%"]
        options = [ phrases.length.times.collect {|e| "#{substitute.include?(which) ? substitute[which] : which} LIKE ?" }.join(" OR ") ] + phrases.collect {|e| "%#{e}%" }
      end
      { :include => :user, :conditions => options }
    }
  end

  # # we want to chain this with other named_scopes or queries
  # # this is a UNION type query, so we need this additional named_scope
  # named_scope :filtered_like, lambda {|*args|
  #   # collect comma separated uniq values in array
  #   phrases = (args.flatten.first || '').split(',').collect(&:strip).compact.uniq
  #   if args.blank?
  #     options = {} # just like "all"
  #   else
  #     options = [ phrases.length.times.collect {|e| "users.name LIKE ? OR serial_number LIKE ?" }.join(" OR ") ] + phrases.collect {|e| ["%#{e}%", "%#{e}%"] }.flatten
  #   end
  #   { :include => :user, :conditions => options }
  # }
  
  before_save :get_user_from_serial

  def validate
    if !termination_requested_on.blank?
      #self.errors.add( "Discontinue billing from which date?") if discontinue_bill_on.blank?
      #self.errors.add( "Discontinue service from which date?") if discontinue_service_on.blank?
    end
  end
  
  # methods for views
  #
  def user_name; return (user.blank? ? '' : user.name); end
  def user_name=(name); user = User.find_by_login(name); end
  def group_name; return (group.blank? ? '' : group.name); end
  def group_name=(name); group = Group.find_by_name(name); end
  
  # fetch user_id from serial number
  #
  def get_user_from_serial
    device_info = DeviceInfo.find_by_serial_number(serial_number)
    user_id = device_info.user_id unless device_info.blank?
  end
  
  # status of RMA computed from statuses of RMA items
  #
  def computed_status
    arr = rma_items.collect(&:status).compact.uniq
    if arr.length == 1 && arr[0] == 'New'
      status = 'New'
    elsif arr.length == 1 && arr[0] == 'Completed'
      status = 'Completed'
    else
      status = ( arr.blank? ? '' : 'Waiting' )
    end
  end
  
  def computed_status_detail
    statuses = {}
    arr = rma_items.collect(&:status)
    # New Logic: Shows all status types, but only when they exist
    #
    arr.each {|e| statuses[e] ||= 0; statuses[e] += 1 } # instantiate if not already, increase count by one
    # Old logic: Only show New, Completed or Waiting
    #
    # ['New', 'Completed'].each do |status|
    #   statuses[status] = arr.select {|p| p == status}.length
    # end
    # statuses['Waiting'] = (arr - ['New', 'Completed']).length
    return ( arr.blank? ? 'No RMA Items' : statuses )
  end
end