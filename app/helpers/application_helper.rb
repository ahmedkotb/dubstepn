require 'tempfile'

module ApplicationHelper
  def markdown(s)
    file = Tempfile.new "markdown"
    file.write(s)
    file.close
    result = `perl ./script/markdown.pl #{file.path}`
    file.unlink
    return result
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

  def backtrack(*blacklist)
    if session[:routes] != nil
      while session[:routes].size > 0
        pair = session[:routes].pop
        if blacklist.select { |route|
          if route.instance_of?(Regexp)
            (pair[0] =~ route) != nil
          else
            pair[0] == route
          end
        }.empty?
          return redirect_to pair[1]
        end
      end
    end
    return redirect_to "/"
  end
end
