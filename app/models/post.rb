class Post < ActiveRecord::Base
  attr_accessible :title, :content, :is_public, :parent
end
