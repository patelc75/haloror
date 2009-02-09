class DeleteAttOptionInFavorOfAttCingularOption < ActiveRecord::Migration
  def self.up
    att = Carrier.find_by_domain('@mmode.com')
    Carrier.delete(att.id)
  end

  def self.down
  end
end
