class FixRedirect < ActiveRecord::Migration
  def up
    change_column :redirects, :from, :text, :null => false
    change_column :redirects, :to, :text, :null => false
    change_column :redirects, :created_at, :timestamp, :null => false
    change_column :redirects, :updated_at, :timestamp, :null => false
    change_column :posts, :created_at, :timestamp, :null => false
    change_column :posts, :updated_at, :timestamp, :null => false
    change_column :tags, :created_at, :timestamp, :null => false
    change_column :tags, :updated_at, :timestamp, :null => false
  end

  def down
    change_column :redirects, :from, :text
    change_column :redirects, :to, :text
    change_column :redirects, :created_at, :timestamp
    change_column :redirects, :updated_at, :timestamp
    change_column :posts, :created_at, :timestamp
    change_column :posts, :updated_at, :timestamp
    change_column :tags, :created_at, :timestamp
    change_column :tags, :updated_at, :timestamp
  end
end
