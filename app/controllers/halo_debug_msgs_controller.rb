class HaloDebugMsgsController < RestfulAuthController
  def index
    @halo_debug_msgs = HaloDebugMsg.find(:all)
  end
end
