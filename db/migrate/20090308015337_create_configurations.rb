class CreateConfigurations < ActiveRecord::Migration
  class Configuration < ActiveRecord::Base
  end

  def self.up
    create_table :configurations do |t|
      t.string :email, :default => "brushup@example.com", :null => false
      t.string :google_analytics,  :default => "", :null => false
      t.string :google_adsense, :default => "", :null => false

      t.timestamps
    end

    Configuration.reset_column_information
    Configuration.create!
  end
  
  def self.down
    drop_table :configurations
  end
end
