include ApplicationHelper
require 'date'
require 'digest'
require 'open-uri'

class HomeController < ApplicationController
  before_filter :authenticate, :only => [:admin]

  def index
  end

  def resume
    data = open("http://s3.amazonaws.com/dubstepn/resume.pdf").read
    send_data data, :type => "application/pdf", :disposition => "inline"
  end

  def admin
    #Post.create(:title => "First Post", :content => "Here is some content!", :tags => "programming", :visible => true)

    @posts = Post.all
  end

  def login
  end

  def logout
    session[:login_time] = nil
    flash[:notice] = "You are now logged out."
    return redirect_to "/"
  end

  def credentials
    if params[:password]
      if Digest::MD5.hexdigest(params[:password]) == "06b56586df6e470347ec246394d07172"
        session[:login_time] = DateTime.now
        flash[:notice] = "You are now logged in."
        return redirect_to "/admin"
      end
    end
    flash[:error] = "The password was incorrect."
    return redirect_to "/login"
  end

  private
    def authenticate
      if session[:login_time] == nil
        return redirect_to "/login"
      end
      if session[:login_time].advance(:hours => 1) < DateTime.now
        return redirect_to "/login"
      end
    end
end
