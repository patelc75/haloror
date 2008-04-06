class SetDefaultValuesForAlertTypes < ActiveRecord::Migration
  def self.up
    AlertType.find(:all).each do |type|
      type.phone_active = false
      type.email_active = false
      type.text_active = false
      type.save
    end
  end

  def self.down
  end
end
