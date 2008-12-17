class CreateReminders < ActiveRecord::Migration
  def self.up
    create_table :reminders do |t|
      t.belongs_to :user
      t.belongs_to :schedule
      t.string :title
      t.text :body
      t.boolean :public
      t.boolean :leared

      t.timestamps
    end
  end

  def self.down
    drop_table :reminders
  end
end
