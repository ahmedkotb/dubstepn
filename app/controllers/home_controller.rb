require 'tempfile'

class HomeController < ApplicationController
  def index
    file = Tempfile.new "markdown"
    file.write("hello world")
    file.close
    @test = `perl ./script/markdown.pl #{file.path}`
    file.unlink
  end
end
