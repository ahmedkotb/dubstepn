class Post < ActiveRecord::Base
  attr_accessible :title, :content, :is_public, :parent_id
  has_and_belongs_to_many :tags
  has_many :children, :class_name => "Post", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Post"
end
