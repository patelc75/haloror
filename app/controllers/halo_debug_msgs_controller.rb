class HaloDebugMsgsController < RestfulAuthController
  def index
    @halo_debug_msgs = HaloDebugMsgs.find(:all)
  end
end
