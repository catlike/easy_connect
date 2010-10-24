class SiteController < ApplicationController
  def index
    @title = "Welcome to EasyConnect"
  end

  def help
    @title = "EasyConnect Help"
  end

  def about
    @title = "About EasyConnect"
  end

end
