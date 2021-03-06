require 'net/https'
require 'tempfile'

module ApplicationHelper
  # metadata used in various places
  APP_DESCRIPTION = ENV['APP_DESCRIPTION']
  APP_TITLE = ENV['APP_TITLE']
  APP_AUTHOR = ENV['APP_AUTHOR']
  APP_EMAIL = ENV['APP_EMAIL']
  APP_PROTOCOL = ENV['APP_PROTOCOL']
  APP_HOST = ENV['APP_HOST']
  APP_RESUME_URL = ENV['APP_RESUME_URL']
  APP_PASSWORD_HASH = ENV['APP_PASSWORD_HASH']

  if !APP_DESCRIPTION ||
     !APP_TITLE ||
     !APP_AUTHOR ||
     !APP_EMAIL ||
     !APP_PROTOCOL ||
     !APP_HOST ||
     !APP_RESUME_URL ||
     !APP_PASSWORD_HASH
    raise 'Required environment variables not set.'
  end

  # converts markdown into html
  # does some extra processing:
  # - replaces ' and " with their directional counterparts
  # - replaces <pre><code>...</code></pre> with <pre>...</pre> (inline code gets put in <code> tags whereas block code gets put in <pre> tags)
  # - shifts all headings by 2 (so h1 -> h3, h2 -> h4, etc.)
  # s :: String
  def markdown(s)
    raise if !s.instance_of?(String)
    
    file = Tempfile.new 'markdown'
    file.write(s)
    file.close
    result = `perl ./script/markdown.pl #{file.path}`
    file.unlink

    def char_is_raw(str, pos)
      left = str[0...pos]
      pre_open = left.scan(/\<pre\>/).length
      pre_close = left.scan(/\<\/pre\>/).length
      code_open = left.scan(/\<code\>/).length
      code_close = left.scan(/\<\/code\>/).length
      script_open = left.scan(/\<script\>/).length
      script_close = left.scan(/\<\/script\>/).length
      style_open = left.scan(/\<style\>/).length
      style_close = left.scan(/\<\/style\>/).length
      math_open = left.scan(/\\\(/).length
      math_close = left.scan(/\\\)/).length
      tag_level = 0
      (0...pos).each do |i|
        if str[i] == '<'
          tag_level += 1
        end
        if str[i] == '>'
          tag_level -= 1
          if tag_level < 0
            tag_level = 0
          end
        end
      end
      return pre_open <= pre_close && code_open <= code_close && math_open <= math_close && script_open <= script_close && style_open <= style_close && tag_level == 0
    end

    pos = result.length - 1
    double_quote_parity = true
    while pos >= 0
      if result[pos] == '\'' && char_is_raw(result, pos)
        result = result[0...pos] + '&rsquo;' + result[(pos + 1)..result.length]
      end
      if result[pos] == '"' && char_is_raw(result, pos)
        if double_quote_parity
          result = result[0...pos] + '&rdquo;' + result[(pos + 1)..result.length]
        else
          result = result[0...pos] + '&ldquo;' + result[(pos + 1)..result.length]
        end
        double_quote_parity = !double_quote_parity
      end
      pos -= 1
    end

    result.gsub!('<pre><code>', '<pre>')
    result.gsub!('</code></pre>', '</pre>')
    result.gsub!('<h6>',  '<p>')
    result.gsub!('</h6>', '</p>')
    result.gsub!('<h5>',  '<p>')
    result.gsub!('</h5>', '</p>')
    result.gsub!('<h4>',  '<h6>')
    result.gsub!('</h4>', '</h6>')
    result.gsub!('<h3>',  '<h5>')
    result.gsub!('</h3>', '</h5>')
    result.gsub!('<h2>',  '<h4>')
    result.gsub!('</h2>', '</h4>')
    result.gsub!('<h1>',  '<h3>')
    result.gsub!('</h1>', '</h3>')
    result.gsub!('<p>', '<div class="p">')
    result.gsub!('</p>', '</div>')

    return result
  end

  # call this if the markdown(...) function above ever changes to re-markdown all existing posts
  def remarkdown_all_posts!
    for post in Post.all
      post.markdown!
      post.save
    end
  end

  # this function crawls the website and tries to follow every link
  # it prints the results to stdout and returns nothing
  # don't call this from within a web request or you'll get an infinite loop because
  # this function will try to make a request but the server won't be able to handle it
  # since it's already handling the request that invoked this
  def test_links
    # URLs to crawl
    # each item in this list is of the form [url, referrer]
    # referrer is nil for the root
    agenda = [['/', nil]]

    # URLs we have crawled already
    # each item in this list is of the form [url, referrer, error]
    # error is nil on success
    visited = []

    # crawl the website
    while agenda.size > 0
      # take a URL from the agenda
      pair = agenda.pop
      url = pair[0]
      referrer = pair[1]
      print '.'

      # get a complete version of the URL
      full_url = url
      if full_url.size == 0
        full_url = '/'
      end
      if full_url.start_with?('//')
        full_url = APP_PROTOCOL + full_url[2..-1]
      elsif full_url.start_with?('/')
        full_url = APP_PROTOCOL + APP_HOST + full_url
      end

      # try to fetch the URL
      begin
        uri = URI.parse(full_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        res = http.get(uri.request_uri)
      rescue Exception => e
        visited.push([url, referrer, e.to_s])
        next
      end

      # check the response code
      if res.code != '200'
        visited.push([url, referrer, 'response code: ' + res.code])
        next
      end

      # for local pages, parse the body for hyperlinks
      if url.start_with?('/')
        new_urls = []
        new_urls += res.body.scan(/\<a.*href\=\"([^"]*)\".*\>[^<]*\<\/a\>/).map { |result| result[0] }
        new_urls += res.body.scan(/\<a.*href\=\'([^']*)\'.*\>[^<]*\<\/a\>/).map { |result| result[0] }
        for new_url in new_urls
          new_url = CGI.unescapeHTML(new_url)
          if new_url == url
            next
          end
          if agenda.map { |result| result[0] }.include?(new_url)
            next
          end
          if visited.map { |result| result[0] }.include?(new_url)
            next
          end
          agenda.push([new_url, url])
        end
      end

      # add the url to the visited list and continue
      visited.push([url, referrer, nil])
    end
    puts ''
    puts ''

    # print the successful urls
    puts 'Successful URLs:'
    puts ''
    for item in visited.sort { |a, b| a[0] <=> b[0] }
      if item[2] == nil
        if item[1] == nil
          puts '* ' + item[0]
        else
          puts '* ' + item[0] + ' from ' + item[1]
        end
      end
    end
    puts ''

    # print the failed urls
    puts 'Failed URLs:'
    puts ''
    for item in visited.sort { |a, b| a[0] <=> b[0] }
      if item[2] != nil
        if item[1] == nil
          puts '* ' + item[0] + ': ' + item[2]
        else
          puts '* ' + item[0] + ' from ' + item[1] + ': ' + item[2]
        end
      end
    end
    return
  end

  # return whether the user is logged in
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
