# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_easy_connect_session',
  :secret      => 'f999300e04824bc7fb1468e27a7f4df04350ef6677bb4dac08d8f12ffefcda2d70724ac7b591556c07bf1dd6888f376eda57b64e114c75a452a36f907a86f1c6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
