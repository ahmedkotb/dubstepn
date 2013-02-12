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

  def record_route(name)
    if request.get?
      if session[:routes] == nil
        session[:routes] = [[name, request.fullpath]]
      else
        session[:routes].push([name, request.fullpath])
        session[:routes] = session[:routes].last(5)
      end
    end
  end

  def remove_routes(*blacklist)
    if session[:routes] != nil
      session[:routes].select! { |pair|
        blacklist.select { |route|
          if route.instance_of?(Regexp)
            (pair[0] =~ route) != nil
          else
            pair[0] == route
          end
        }.empty?
      }
    end
  end

  def backtrack()
    if session[:routes] && session[:routes].size > 0
      pair = session[:routes].pop
      return redirect_to pair[1]
    end
    return redirect_to "/"
  end
end
