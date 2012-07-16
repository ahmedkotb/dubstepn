class Post < ActiveRecord::Base
  attr_accessible :title, :content, :public, :parent
end
