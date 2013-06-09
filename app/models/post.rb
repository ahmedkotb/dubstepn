class Post < ActiveRecord::Base
  attr_accessible :title, :content, :content_html, :javascript, :css, :is_public, :sort_id
  has_and_belongs_to_many :tags
  has_many :children, :class_name => "Post", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Post"

  # get a short summary of this post for SEO
  def summary
    # start with the markdown
    summary = self.content

    # remove html tags
    summary.gsub!(/\<[^>]*\>/, "")

    # remove titles
    summary.gsub!(/^\#.*$/, " ")

    # escape sequences
    summary.gsub!(/\\\(/, "(")
    summary.gsub!(/\\\)/, ")")
    summary.gsub!(/\\\\/, "\\")

    # remove math markup
    summary.gsub!(/\\\( *([^\\ ]*) *\\\)/, "\\1")

    # replace hyperlinks with their text
    summary.gsub!(/\[([^\]]*[^\\])\]\([^\)]*[^\\]\)/, "\\1")

    # remove leading and trailing whitespace
    summary.strip!

    # take the first 155 characters
    if summary.length > 155
      summary = summary.first(155).split.reverse.drop(1).reverse.join(" ") + "..."
    else
      summary = summary.split.join(" ")
    end

    # return the result
    return summary
  end

  # get the canonical URI for this post
  def canonical_uri
    return "/post/#{ self.id.to_s }/#{ URI::encode(self.title.downcase.gsub(/[\"\']/, "").gsub(/[^a-z0-9]/, "-").gsub(/-+/, "-").gsub(/\A-/, "").gsub(/-\Z/, "")) }"
  end
end
