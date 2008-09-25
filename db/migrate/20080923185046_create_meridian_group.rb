class CreateMeridianGroup < ActiveRecord::Migration
  def self.up
    now = Time.now
    Group.create(:name => 'meridian', :created_at => now, :updated_at => now)
  end

  def self.down
  end
end
