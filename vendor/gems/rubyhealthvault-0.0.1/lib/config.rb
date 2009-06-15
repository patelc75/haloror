# -*- ruby -*-
#--
# Copyright 2008 Danny Coates, Ashkan Farhadtouski
# All rights reserved.
# See LICENSE for permissions.
#++

require 'logger'
require 'singleton'

module HealthVault
  class Configuration
    include Singleton
    attr_accessor :app_id, :cert_file, :cert_pass, :shell_url, :hv_url, :logger
    
    #thess should be set by your application
    #using HealthVault::Configuration.instance accessor methods
    def initialize
      @app_id = "6019e8f1-413f-4dfc-878e-62053cbb0dab"
      @cert_file = "#{RAILS_ROOT}/config/halo_monitor-6019e8f1-413f-4dfc-878e-62053cbb0dab.pfx"
      @cert_pass = ""
      @shell_url = "https://account.healthvault-ppe.com"
      @hv_url = "https://platform.healthvault-ppe.com/platform/wildcat.ashx"
      @logger = RAILS_DEFAULT_LOGGER
    end
  end
end