# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  #Return a link for us in the layout navigation
  def nav_link(text, controller, action="index")
    return link_to_unless_current text, :controller => controller, 
                                        :action => action
  end  
  
  #Return true id some user is logged in, false otherwise
  def logged_in?
    not session[:user_id].nil?
  end  

end
