class CreateOpenidAssociations < ActiveRecord::Migration
  def up
    create_table :openid_associations do |t|
      t.datetime  :issued_at
      t.integer   :lifetime
      t.string    :assoc_type
      t.text      :handle
      t.binary    :secret

      t.string    :target, :size => 32
      t.text      :server_url

      t.timestamps
    end
  end

  def down
    drop_table :openid_associations
  end
end
