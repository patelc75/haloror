# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_haloror_session',
  :secret      => 'eb671213cc805ef96dc302b17b1318a39a90921cfbbf520bfbba5c141695542fd7a52837c36cc55ce8fd22743088f141dda7f6bc5653b16cfd5f95c5ad0c5771'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
