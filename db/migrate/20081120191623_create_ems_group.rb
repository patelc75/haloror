class CreateEmsGroup < ActiveRecord::Migration
  def self.up
    group = Group.new(:name => 'EMS')
    group.save!
    Role.create(:name => 'operator', :authorizable_type => 'Group', :authorizable_id => group.id)
  end

  def self.down
  end
end
