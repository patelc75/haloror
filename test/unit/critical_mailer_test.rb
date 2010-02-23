# require File.dirname(__FILE__) + '/../test_helper'
# 
# class CriticalMailerTest < Test::Unit::TestCase
#   FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
#   CHARSET = "utf-8"
# 
#   include ActionMailer::Quoting
# 
#   def setup
#     ActionMailer::Base.delivery_method = :test
#     ActionMailer::Base.perform_deliveries = true
#     ActionMailer::Base.deliveries = []
# 
#     @expected = TMail::Mail.new
#     @expected.set_content_type "text", "plain", { "charset" => CHARSET }
#     @expected.mime_version = '1.0'
#   end
# 

#   def test_fall
#     @expected.subject = 'CriticalMailer#fall'
#     @expected.body    = read_fixture('fall')
#     @expected.date    = Time.now
# 
#     assert_equal @expected.encoded, CriticalMailer.create_fall(@expected.date).encoded
#   end
# 
#   def test_panic
#     @expected.subject = 'CriticalMailer#panic'
#     @expected.body    = read_fixture('panic')
#     @expected.date    = Time.now
# 
#     assert_equal @expected.encoded, CriticalMailer.create_panic(@expected.date).encoded
#   end
# 
#   private
#     def read_fixture(action)
#       IO.readlines("#{FIXTURES_PATH}/critical_mailer/#{action}")
#     end
# 
#     def encode(subject)
#       quoted_printable(subject, CHARSET)
#     end
# end
