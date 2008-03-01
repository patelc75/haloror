require "base64"
require "digest/sha2"

## Lightweight interface to accept an XML document sent from the
## gateway, along with a HASH of the XML document to ensure it was not
## tampered with. 
#
## A sample url to test:
## http://localhost:3000/gateway/?xml=%3Cmanagement_query_device%3E%3Cdevice_id%3E1%3C%2Fdevice_id%3E%3Ctimestamp%3ESat+Mar+01+18%3A28%3A47+-0500+2008%3C%2Ftimestamp%3E%3Cpoll_rate%3E60%3C%2Fpoll_rate%3E%3C%2Fmanagement_query_device%3E&xml_hash=808fdc7bdca8dbac6221e91f7995c3f7cc5c262f1a64cfc154b1b93290f48e92
class GatewayController < ApplicationController
  session :off
  layout nil

  ## DEFAULT_HASH_KEY used only if there are no firmware upgrades in
  ## the system
  DEFAULT_HASH_KEY="226f3834726d5531683d4f4b5a2d202729695853662543375c226c6447"

  def index
    data = Hash.from_xml(get_hashed_param(:xml))
    render :text => "valid request\n#{data.inspect}"
  end

  def generate_sample
    xml = "<management_query_device><device_id>1</device_id><timestamp>Sat Mar 01 18:28:47 -0500 2008</timestamp><poll_rate>60</poll_rate></management_query_device>"
    xml_hash = Digest::SHA256.hexdigest(DEFAULT_HASH_KEY + xml)
  end
  
  private
  def get_hashed_param(name)
    s = params[name]
    s_hash = params["#{name}_hash"]

    raise "Invalid Request" unless is_hash_valid?(s, s_hash)
    s
  end

  def is_hash_valid?(string, hash)
    FirmwareUpgrade.find(:all).each do |firmware|
      return true if hash == Digest::SHA256.hexdigest(firmware.hash_key + string)
    end
    hash == Digest::SHA256.hexdigest(DEFAULT_HASH_KEY + string)
  end
  
end
