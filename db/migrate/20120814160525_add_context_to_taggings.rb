class AddContextToTaggings < ActiveRecord::Migration
  def change
    ActsAsTaggableOn::Taggings.update_all context: "tags"
    add_column :taggings, :tagger_id, :integer
    add_column :taggings, :tagger_type, :string
  end
end
