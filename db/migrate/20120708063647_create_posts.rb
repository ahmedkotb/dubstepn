class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :title, :null => false
      t.text :content, :null => false
      t.text :tags, :null => false
      t.boolean :visible, :null => false

      t.timestamps
    end
  end
end
