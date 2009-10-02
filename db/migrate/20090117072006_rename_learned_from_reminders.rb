class RenameLearnedFromReminders < ActiveRecord::Migration
  def self.up
    remove_column :reminders, :learned
    add_column :reminders, :learned_at, :date
    change_table :reminders do |t|
      t.date :next_learn_date
    end
  end

  def self.down
    add_column :reminders, :learned, :boolean
    remove_column :reminders, :learned_at
    change_table :reminders do |t|
      t.remove :next_learn_date
    end
  end
end
