class AddContextToTaggings < ActiveRecord::Migration
  def change
    add_column :taggings, :context, :string, :limit => 128, :default => "tags"
    ActsAsTaggableOn::Taggings.update_all context: "tags"
    add_column :taggings, :tagger_id, :integer
    add_column :taggings, :tagger_type, :string
  end
end
