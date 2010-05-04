require File.dirname(__FILE__) + '/../spec_helper'

describe 'EventActionObserver' do
        before :each do
                CriticalMailer.stub!(:deliver_call_center_operator).and_return(:default_value)
                @event_action = EventAction.new(:description => 'accepted', :user_id => 1)
                @observer = EventActionObserver.instance
        end

        # it "should invoke after_save on the observed object" do
        #         @observer.should_receive(:send_to_backup).with("accepted", @event_action)
        #         @observer.before_save(@event_action)
        # end
end
