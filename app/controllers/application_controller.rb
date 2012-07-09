class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_optional_error_file(status_code)
    if status_code == :not_found
      render_404
    else
      super
    end
  end

private
  def render_404
    respond_to do |type| 
      type.html { render :template => "home/notfound", :layout => "application", :status => 404 } 
      type.all  { render :nothing => true, :status => 404 } 
    end
    true
  end

end
