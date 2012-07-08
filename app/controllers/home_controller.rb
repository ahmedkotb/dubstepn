include ApplicationHelper
require 'open-uri'

class HomeController < ApplicationController
  def index
  end

  def resume
    data = open("http://s3.amazonaws.com/dubstepn/resume.pdf").read
    send_data data, :type => "application/pdf", :disposition => "inline"
  end

  def admin
  end
end
