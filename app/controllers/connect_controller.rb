class ConnectController < ApplicationController
  def index
    @title = "EasyConnect"
  end

  def show
    screen_name = params[:screen_name]
    @user = User.find_by_screen_name(screen_name)
    if @user
      @title = "EasyConnect for #{screen_name}"
    else
      flash[:notice] = "No user #{screen_name} at EasyConnect"
      redirect_to :action => "index"
    end    
  end

end
