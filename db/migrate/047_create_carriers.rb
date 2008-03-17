class CreateCarriers < ActiveRecord::Migration
  def self.up
    create_table :carriers do |t|
      t.column :id, :primary_key, :null => false 
      t.column :name, :string
      t.column :domain, :string
    end
    Carrier.create(:name => "Cingular (now AT&T)", :domain => "@cingularme.com")
    Carrier.create(:name => "Verizon", :domain => "@vtext.com")
    Carrier.create(:name => "Boost Mobile", :domain => "@myboostmobile.com")
    Carrier.create(:name => "Nextel", :domain => "@messaging.nextel.com")
    Carrier.create(:name => "Alltel", :domain => "@message.alltel.com")
    Carrier.create(:name => "Sprint PCS", :domain => "@messaging.sprintpcs.com")
    Carrier.create(:name => "AT&T Wireless", :domain => "@mmode.com")
    Carrier.create(:name => "Virgin Mobile USA", :domain => "@vmobl.com")
    Carrier.create(:name => "T-Mobile", :domain => "@tmomail.net ")
    Carrier.create(:name => "Not in the list", :domain => "@teleflip.com")
   
  end

  def self.down
    drop_table :carriers
  end
end
