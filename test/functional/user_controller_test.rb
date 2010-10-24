require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'user_controller'

#Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < ActionController::TestCase
  include ApplicationHelper

  def setup
    @controller = UserController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @valid_user = users(:valid_user)
  end

  #Make sure the registration page reponds with the proper form.
  def test_registration
    get :register
    title = assigns(:title)
    assert_equal "Register", title
    assert_response :success
    assert_template "register"

    #Test the form and it's tags
    assert_tag "form",
      :attributes => { :action => "/user/register",
                       :method => "post" }

      assert_tag "input",
      :attributes => { :name => "user[screen_name]",
                       :type => "text",
                       :size => User::SCREEN_NAME_SIZE,
                       :maxlength => User::SCREEN_NAME_MAX_LENGTH }

      assert_tag "input",
      :attributes => { :name => "user[email]",
                       :type => "text",
                       :size => User::EMAIL_SIZE,
                       :maxlength => User::EMAIL_MAX_LENGTH }

      assert_tag "input",
      :attributes => { :name => "user[password]",
                       :type => "password",
                       :size => User::PASSWORD_SIZE,
                       :maxlength => User::PASSWORD_MAX_LENGTH }

      assert_tag "input",
      :attributes => { :type => "submit",
                       :value => "Register!" }
                       
      assert_screen_name_field
      assert_email_field
      assert_password_field
      assert_submit_button "Register!"                 

      end

  def test_registration_success
    post :register, :user => { :screen_name => "new_screen_name",
                               :email => "valid@email.com",
                               :password => "long_enough_to_pass" }

    user = assigns(:user)
    assert_not_nil user

    #Test new user in the database
    new_user = User.find_by_screen_name_and_password(user.screen_name, user.password)
    assert_equal new_user, user

    #Test flash and redirect
    assert_equal "User #{new_user.screen_name} created!", flash[:notice]
    assert_redirected_to :action => "index"

    assert logged_in?
    assert_equal user.id, session[:user_id]

  end

  def test_registration_failure
    post :register, :user => { :screen_name => "in/valid",
                               :email => "noway@thisworks,com",
                               :password => nil }

    assert_response :success
    assert_template "register"

    #Test display of error messages
    assert_tag "div", :attributes => { :id => "errorExplanation",
                                       :class => "errorExplanation" }

    #Test that each form field has at least 1 error
    assert_tag "li", :content => /Screen name/
    assert_tag "li", :content => /Email/
    assert_tag "li", :content => /Password/

    #Test yo see that the input fields are being wrapped with the correct div
    error_div = { :tag => "div", :attributes => { :class => "fieldWithErrors"} }

    assert_tag "input",
      :attributes => { :name => "user[screen_name]",
                       :value => "in/valid" },
      :parent => error_div

    assert_tag "input",
      :attributes => { :name => "user[email]",
                       :value => "noway@thisworks,com" },
      :parent => error_div

    assert_tag "input",
      :attributes => { :name => "user[password]",
                       :value => nil },
      :parent => error_div

  end

  def test_login_page
    get :login
    title = assigns(:title)
    assert_equal "Login to EasyConnect", title
    assert_response :success
    assert_template "login"

    assert_tag "form",
      :attributes => { :action => "/user/login",
                       :method => "post" }

      assert_tag "input",
      :attributes => { :name => "user[screen_name]",
                       :type => "text",
                       :size => User::SCREEN_NAME_SIZE,
                       :maxlength => User::SCREEN_NAME_MAX_LENGTH }

      assert_tag "input",
      :attributes => { :name => "user[password]",
                       :type => "password",
                       :size => User::PASSWORD_SIZE,
                       :maxlength => User::PASSWORD_MAX_LENGTH }

      assert_tag "input",
      :attributes => { :type => "submit",
                       :value => "Login"}

      end

  #Test a valid login
  def test_login_sucess
    try_to_login @valid_user
    assert logged_in?
    assert_equal @valid_user.id, session[:user_id]
    assert_equal "#{@valid_user.screen_name} logged in", flash[:notice]
    assert_redirected_to :action => "index"
  end

  def test_login_with_nonexistent_screen_name
    invalid_user = @valid_user
    invalid_user.screen_name = "no such user"
    try_to_login invalid_user
    assert_template "login"
    assert_equal "Invalid screen name/password combination", flash[:notice]
    #Make sure the screenname will be redisplayed, but not the password
    user = assigns(:user)
    assert_equal invalid_user.screen_name, user.screen_name
    assert_nil user.password
  end

  def test_login_failure_with_wrong_password
    invalid_user = @valid_user
    invalid_user.password += "addon"
    try_to_login invalid_user
    assert_template "login"
    assert_equal "Invalid screen name/password combination", flash[:notice]
    #Make sure the screenname will be redisplayed, but not the password
    user = assigns(:user)
    assert_equal invalid_user.screen_name, user.screen_name
    assert_nil user.password
  end

  def test_logout
    try_to_login @valid_user
    assert logged_in?
    get :logout
    assert_response :redirect
    assert_equal "Logged out", flash[:notice]
    assert !logged_in?
  end

  def test_nav_logged_in
    authorize @valid_user
    get :index
    assert_tag "a", :content => /Logout/,
      :attributes => { :href => "/user/logout" }

    assert_no_tag "a", :content => /Register/
    assert_no_tag "a", :content => /Login/
  end

  def test_index_unathorized
    #Make sure the before filter is working
    get :index
    assert_response :redirect
    assert_redirected_to :action => "login"
    assert_equal "Please login first", flash[:notice]
  end

  def test_index_authorized
    authorize @valid_user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_login_friendly_url_forwarding
    user = { :screen_name => @valid_user.screen_name,
             :password => @valid_user.password }
    friendly_url_forwarding_aux(:login, :index, user)
  end

  def test_register_friendly_url_forwarding
    user = { :screen_name => "new_screen_name",
             :email => "valid@example.com",
             :password => "long_enough_to_work" }
    friendly_url_forwarding_aux(:register, :index, user)
  end
  
  def test_edit_page
    authorize @valid_user
    get :edit
    title = assigns(:title)
    assert_equal "Edit basic info", title
    assert_response :success
    assert_template :edit
    
    assert_form_tag "/user/edit"
    assert_email_field @valid_user.email
    assert_password_field "current_password"
    assert_password_field
    assert_password_field "password_confirmation"
    assert_submit_button "Update"
  end  

  private

    def try_to_login(user)
      post :login, :user => { :screen_name => user.screen_name,
                              :password => user.password}
    end

    def authorize(user)
      @request.session[:user_id] = user.id
    end

    def friendly_url_forwarding_aux(test_page, protected_page, user)
      get protected_page
      assert_response :redirect
      #      assert_redirected_to :action => "login"
      post test_page, :user => user
      assert_response :redirect
      assert_redirected_to :action => protected_page
      #Make sure the forwarding url has been cleared
      assert_nil session[:protected_page]
    end

    #Assert that the email field has the correct HTML
    def assert_email_field(email = nil, options = {})
      assert_input_field("user[email]", email, "text", User::EMAIL_SIZE, User::EMAIL_MAX_LENGTH, options)
    end
    
    def assert_password_field(password_field_name = "password", options = {})
      blank = nil
      assert_input_field("user[#{password_field_name}]", blank, "password", User::PASSWORD_SIZE, User::PASSWORD_MAX_LENGTH, options)
    end
    
    def assert_screen_name_field(screen_name = nil, options = {})
      assert_input_field("user[screen_name]", screen_name, "text", User::SCREEN_NAME_SIZE, User::SCREEN_NAME_MAX_LENGTH, options)
    end    


end
