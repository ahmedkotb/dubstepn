class Post < ActiveRecord::Base
  attr_accessible :title, :content, :is_public, :parent
  has_and_belongs_to_many :tags
end
