class RenamePublicFromReminder < ActiveRecord::Migration
  def self.up
    change_table :reminders do |t|
      t.rename :public, :completed
    end
  end

  def self.down
    change_table :reminders do |t|
      t.rename :completed, :public
    end
  end
end
