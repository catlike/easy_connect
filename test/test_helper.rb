ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  #Assert the form tag
  def assert_form_tag(action)
    assert_tag "form", :attributes => { :action => action,
                                        :method => "post" }
  end

  def assert_submit_button(button_label = nil)
    if button_label
      assert_tag "input", :attributes => { :type => "submit",
                                           :value => button_label }
    else
      assert_tag "input", :attributes => { :type => "submit" }
    end
  end

  def assert_input_field(name, value, field_type, size, maxlength, options = {})
    attributes = { :name => name,
                   :type => field_type,
                   :size => size,
                   :maxlength => maxlength }
    attributes[:value] = value unless value.nil?
    tag = { :tag => "input",
            :attributes => attributes }
    tag.merge!(options)
    assert_tag tag
  end
  
  def assert_length(boundary, object, attribute, length, options = {} )
    valid_char = options[:valid_char] || "a"
    barely_invalid = barely_invalid_string(boundary, length, valid_char)
    #Test over the boundary
    object[attribute] = barely_invalid
    assert !object.valid?
      "#{object[attribute]} (length #{object[attribute].length}) " + "should raise a length error"
#    assert_equal correct_error_message(boundary, length), object.errors.on(attribute)
    
    #Test the boundary itself
    barely_valid = valid_char * length
    object[attribute] = barely_valid
    assert object.valid?
      "#{object[attribute]} (length #{object[attribute].length}) " + "should be on the boundary of validity"
  end
  
  def barely_invalid_string(boundary, length, valid_char)
    if boundary == :max
      invalid_length = length + 1
    elsif boundary == :min
      invalid_length = length - 1
    else
      raise ArguementError, "boundary must be :max or :min"
    end
    valid_char * invalid_length
  end
  
  def correct_error_message(boundary, length)
    error_messages = ActiveRecord::Errors.default_error_messages
    if boundary == :max
#      sprintf(error_messages[:too_long], length)
    elsif boundary == :min
#      sprintf(error_messages[:too_short], length)
    else
      raise ArguementError, "boundary must be :max or :min"
    end
  end                  
end
