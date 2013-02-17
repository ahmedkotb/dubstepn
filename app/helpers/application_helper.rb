require 'tempfile'

module ApplicationHelper
  def markdown(s)
    file = Tempfile.new "markdown"
    file.write(s)
    file.close
    result = `perl ./script/markdown.pl #{file.path}`
    file.unlink
    result.gsub!("<pre><code>", "<pre class=\"brush: plain; toolbar: false;\">")
    result.gsub!("</code></pre>", "</pre>")
    result.gsub!("<h6>",  "<p>")
    result.gsub!("</h6>", "</p>")
    result.gsub!("<h5>",  "<p>")
    result.gsub!("</h5>", "</p>")
    result.gsub!("<h4>",  "<h6>")
    result.gsub!("</h4>", "</h6>")
    result.gsub!("<h3>",  "<h5>")
    result.gsub!("</h3>", "</h5>")
    result.gsub!("<h2>",  "<h4>")
    result.gsub!("</h2>", "</h4>")
    result.gsub!("<h1>",  "<h3>")
    result.gsub!("</h1>", "</h3>")
    return result
  end

  def remarkdown_all_posts!
    for post in Post.all
      post.content_html = markdown(post.content)
      post.save
    end
  end

  def is_logged_in
    if session[:login_time] == nil
      return false
    end
    if session[:login_time].advance(:hours => 1) < DateTime.now
      return false
    end
    return true
  end
end
