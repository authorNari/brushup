class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.integer :level
      t.integer :span

      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
