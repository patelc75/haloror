class SetInitialCallCenterFaq < ActiveRecord::Migration
  def self.up
    faq_text = <<-eos
      <b><h1>Call Center Wizard FAQ</h1</b>

      <pre>
      Q. "What is a gateway?"

      A. Your gateway is the box installed in your home that communicates with your chest strap.  It has green and red lights and beeps.


      Q. "Can you please call someone else instead of my caregivers?

      A. No, we are not allowed to call alternate numbers


      Q.

      A.


      Q.

      A.


      Q.

      A.
      </pre>
    eos
    faq = CallCenterFaq.new(:faq_text => faq_text)
    faq.save!
  end

  def self.down
  end
end
