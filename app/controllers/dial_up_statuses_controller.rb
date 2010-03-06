class DialUpStatusesController < RestfulAuthController
  layout 'application'
  session :on,:except => :create
  
  def index
    # WARNING: Not tested
    # 1. using named scopes to filter the data. Paginate will just do what it says
    # 2. 'Select Type' also get covered because no matching record will be found anyways
    # FIXME: extra query fired here. Can be DRYed
    #  This logic is causing one database search every time. Needs conditional code for speed optimization.
    @dial_up_statuses = \
      DialUpStatus.by_dialup_type(params[:dialup_type]).by_device_id(params[:device_id]).paginate \
      :page => params[:page], \
      :order => 'created_at desc', \
      :per_page => 50
    # conditions = "1=1"
    # conditions += " and device_id = #{params[:device_id]}" \
    #   if params[:device_id] and params[:device_id] != ""
    #     
    # conditions += " and dialup_type = '#{params[:dialup_type]}'" \
    #   if params[:dialup_type] && params[:dialup_type] != 'Select Type'
    #     
    # @dial_up_statuses = DialUpStatus.paginate :page => params[:page], \
    #                                           :conditions => conditions, \
    #                                           :order => 'created_at desc', \
    #                                           :per_page => 50
  end

  def last_successful
    # WARNING: Not tested
    @dial_up_last_successfuls = DialUpLastSuccessful.by_device_id(params[:device_id]).paginate \
      :page => params[:page], \
      :order   => 'created_at desc', \
      :per_page => 20

    # if params[:device_id] and params[:device_id] != ""
    #   @dial_up_last_successfuls = DialUpLastSuccessful.paginate :page => params[:page],:conditions => ["device_id = ?",params[:device_id]],:order   => 'created_at desc',:per_page => 20
    # else
    #   @dial_up_last_successfuls = DialUpLastSuccessful.paginate :page => params[:page],:order   => 'created_at desc',:per_page => 20
    # end
  end

  # new data posted from user-agent
  #
  def create
    debugger
    #
    # get the hashes separate for each row of AR
    # WARNING: Not tested
    split_dial_up_status_hash_and_create_tuples( params[:dial_up_status] )
    
    # request = params[:dial_up_status]
    # DialUpStatus.process_xml_hash(request)
    render :nothing => true
  end
end