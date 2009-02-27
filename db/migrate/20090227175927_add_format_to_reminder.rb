class AddFormatToReminder < ActiveRecord::Migration
  def self.up
    add_column :reminders, :format, :string
  end

  def self.down
    remove_column :reminders, :format
  end
end
