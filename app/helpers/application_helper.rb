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
end
