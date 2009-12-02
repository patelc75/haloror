class CreateSafetyCareGroup < ActiveRecord::Migration
  def self.up
  	group = Group.new(:name => 'safety_care')
    group.save!
    Role.create(:name => 'operator', :authorizable_type => 'Group', :authorizable_id => group.id)
  end

  def self.down
  end
end
