namespace :halo do  
  desc "populate device types"
  task :populate_device_types => :environment  do
    Device.find(:all, :conditions =>"serial_number like 'H1%'").each do |device|
      device.device_revision_id = 1
      device.save!
    end
    Device.find(:all, :conditions =>"serial_number like 'H2%'").each do |device|
      device.device_revision_id = 2
      device.save!
    end
  end
end