class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :openid_url
      t.string :login

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
