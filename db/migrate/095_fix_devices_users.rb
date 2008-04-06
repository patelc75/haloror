class FixDevicesUsers < ActiveRecord::Migration

  def self.up
    execute "alter table devices_users drop column id"
  end

  def self.down
    execute "alter table devices_users add column id serial primary key"
  end

end
