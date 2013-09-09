class CreateRedirects < ActiveRecord::Migration
  def change
    create_table :redirects do |t|
      t.text :from
      t.text :to

      t.timestamps
    end
  end
end
