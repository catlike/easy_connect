class UserController < ApplicationController
  include ApplicationHelper

  before_filter :protect, :only => [:index, :edit]

  def index
    @title = "EasyConnect Command Center"
    @user = User.find(session[:user_id])
  end

  def register
    @title = "Register"
    if param_posted?(:user)
      @user = User.new(params[:user])
      if @user.save
        @user.login!(session)
        flash[:notice] = "User #{@user.screen_name} created!"
        redirect_to_forwarding_url
      else
        @user.clear_password!
      end
    end
  end

  def login
    @title = "Login to EasyConnect"
    if param_posted?(:user)
      @user = User.new(params[:user])
      user = User.find_by_screen_name_and_password(@user.screen_name, @user.password)
      if user
        user.login!(session)
        flash[:notice] = "#{user.screen_name} logged in"
        redirect_to_forwarding_url
      else
        @user.clear_password!
        flash[:notice] = "Invalid screen name/password combination"
      end
    end
  end

  def logout
    User.logout!(session)
    flash[:notice] = "Logged out"
    redirect_to :action => "index", :controller => "site"
  end
  
  def edit
    @title = "Edit basic info"
    @user = User.find(session[:user_id])
    if param_posted?(:user)
      attribute = params[:attribute]
      case attribute
        when "email"
          try_to_update @user, attribute
        when "password"
          if @user.correct_password?(params)
            try_to_update @user, attribute 
          else
            @user.password_errors(params)
          end     
      end
    end
    #Never fill in a password field
    @user.clear_password!
  end      

  private

    #Protect a page from unathorized access
    def protect
      unless logged_in?
        session[:protected_page] = request.request_uri
        flash[:notice] = "Please login first"
        redirect_to :action => "login"
        return false
      end
    end
    
    #Return true if a param corresponding to the given symbol was posted
    def param_posted?(symbol)
      request.post? and params[symbol]
    end 
    
    def redirect_to_forwarding_url
      if (redirect_url = session[:protected_page])
        session[:protected_page] = nil
        redirect_to redirect_url
      else
        redirect_to :action => "index"
      end
    end 
    
    def try_to_update(user, attribute)
      if user.update_attributes(params[:user])
        flash[:notice] = "#{@user.screen_name} #{attribute} updated."
        redirect_to :action => "index"
      end
    end          

end
