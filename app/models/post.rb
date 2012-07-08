class Post < ActiveRecord::Base
  attr_accessible :content, :title, :visible
end
