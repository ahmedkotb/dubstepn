require 'tempfile'

module ApplicationHelper
  # metadata used in various places
  APP_DESCRIPTION = "Computer science, software engineering, math, and music."
  APP_AUTHOR = "Stephan Boyer"
  APP_EMAIL = "boyers@mit.edu"
  APP_HOST = "www.stephanboyer.com"

  def markdown(s)
    file = Tempfile.new "markdown"
    file.write(s)
    file.close
    result = `perl ./script/markdown.pl #{file.path}`
    file.unlink

    def char_is_raw(str, pos)
      left = str[0...pos]
      pre_open = left.scan(/\<pre\>/).length
      code_open = left.scan(/\<code\>/).length
      pre_close = left.scan(/\<\/pre\>/).length
      code_close = left.scan(/\<\/code\>/).length
      math_open = left.scan(/\\\(/).length
      math_close = left.scan(/\\\)/).length
      tag_open = left.scan(/\</).length
      tag_close = left.scan(/\>/).length
      return pre_open <= pre_close && code_open <= code_close && math_open <= math_close && tag_open <= tag_close
    end

    pos = result.length - 1
    double_quote_parity = true
    while pos >= 0
      if result[pos] == "\'" && char_is_raw(result, pos)
        result = result[0...pos] + "&rsquo;" + result[(pos + 1)..result.length]
      end
      if result[pos] == "\"" && char_is_raw(result, pos)
        if double_quote_parity
          result = result[0...pos] + "&rdquo;" + result[(pos + 1)..result.length]
        else
          result = result[0...pos] + "&ldquo;" + result[(pos + 1)..result.length]
        end
        double_quote_parity = !double_quote_parity
      end
      pos -= 1
    end

    result.gsub!("<pre><code>", "<pre>")
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
    if session[:login_time].advance(:hours => 12) < DateTime.now
      return false
    end
    return true
  end
end
