class AggregatedStatusForUsers < ActiveRecord::Migration
  def self.up
    #
    # migrate in batches to save memory hog
    _highest_id = User.maximum( :id)
    _migrated = 0
    _step = 100
    while _migrated <= _highest_id
      #
      # https://redmine.corp.halomonitor.com/projects/haloror/wiki/Intake_Install_and_Billing#Other-notes
      User.all( :conditions => { :id => (_migrated..(_migrated+_step)) }).each do |user|
        #
        # Only touch legacy users identified as "not having a user intake"
        if user.user_intakes.blank?
          #
          # Legacy halousers will be assigned "installed" state if user is halouser of safety_care.
          # All other halousers, demo boolean is set to true
          if user.is_halouser_of?( Group.safety_care!)
            user.status = User::STATUS[ :installed] # "Installed" if already member of safety_care
          else
            user.demo_mode = true # otherwise just demo_mode account
          end
          user.send( :update_without_callbacks) # just update silently
        end
      end

      print '.'
      _migrated += _step # skip to next batch
    end
    puts " done."
  end

  def self.down
  end
end
