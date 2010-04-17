# require all files in active_merchant_extensions folder under this folder
#
Dir.glob( File.join(File.dirname(__FILE__), "active_merchant_extensions", "**", "*.rb")).each {|file| require file }