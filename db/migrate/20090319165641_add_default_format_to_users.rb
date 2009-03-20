class AddDefaultFormatToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_format, :string
  end

  def self.down
    remove_column :users, :default_format
  end
end
