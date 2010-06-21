# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_WardAreaBook_session',
  :secret      => '175f1bdef67230d466b9608c110ea8d8c7e1db76727e91cc5ee2cae18e4af627dae6fffa42deefd47e66897145ae34781353840805853163722f3e7652563aa7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
