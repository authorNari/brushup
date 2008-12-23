class ChangeToLearnedFromReminders < ActiveRecord::Migration
  def self.up
    change_table :reminders do |t|
      t.rename :leared, :learned
    end
  end

  def self.down
    change_table :reminders do |t|
      t.rename :learned, :leared
    end
  end
end
