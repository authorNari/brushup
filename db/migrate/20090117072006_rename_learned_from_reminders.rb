class RenameLearnedFromReminders < ActiveRecord::Migration
  def self.up
    change_table :reminders do |t|
      t.rename :learned, :learned_at
      t.change :learned_at, :date
      t.date :next_learn_date
    end
  end

  def self.down
    change_table :reminders do |t|
      t.rename :learned_at, :learned
      t.change :learned, :boolean
      t.remove :next_learn_date
    end
  end
end
