class User < ActiveRecord::Base
  attr_accessor :current_password


  # Max and min lengths for all fields
  SCREEN_NAME_MIN_LENGTH  = 4
  SCREEN_NAME_MAX_LENGTH  = 20
  PASSWORD_MIN_LENGTH     = 4
  PASSWORD_MAX_LENGTH     = 40
  EMAIL_MAX_LENGTH        = 50
  SCREEN_NAME_RANGE       = SCREEN_NAME_MIN_LENGTH..SCREEN_NAME_MAX_LENGTH
  PASSWORD_RANGE          = PASSWORD_MIN_LENGTH..PASSWORD_MAX_LENGTH

  #Text box sizes for display in the views
  SCREEN_NAME_SIZE        = 20
  PASSWORD_SIZE           = 10
  EMAIL_SIZE              = 30
  
  PHONE_NUMBER_LENGTH     = 10

  validates_uniqueness_of :screen_name,       :email
  validates_length_of     :screen_name,       :within => SCREEN_NAME_RANGE
  validates_length_of     :password,          :within => PASSWORD_RANGE
  validates_confirmation_of :password
  validates_length_of     :email,             :maximum => EMAIL_MAX_LENGTH

  validates_format_of :screen_name,
    :with => /^[A-Z0-9_]*$/i,
    :message =>"must contain only letters, " + "numbers, and underscores"

  validates_format_of :email,
    :with => /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i,
    :message => "must be a valid email address"

  #Log a user in
  def login!(session)
    session[:user_id] = id
  end

  #Log a user out
  def self.logout!(session)
    session[:user_id] = nil
  end

  #Clear password
  def clear_password!
    self.password = nil
    self.password_confirmation = nil
    self.current_password = nil
  end
  
  def correct_password?(params)
    current_password = params[:user][:current_password]
    password == current_password
  end
  
  def password_errors(params)
    self.password = params[:user][:password]
    self.password_confirmation = params[:user][:password_confirmation]
    valid?
    
    errors.add(:current_password, "is incorrent")
  end    

end
