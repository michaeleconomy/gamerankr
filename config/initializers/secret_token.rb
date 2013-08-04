# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

Rails.application.config.after_initialize do
  Gamerankr::Application.config.secret_token = Secret['rails_secret_token'] ||= rand(2**512).to_s(16)
  Gamerankr::Application.config.secret_key_base = Secret['rails_secret_key_base'] ||= rand(10**20).to_s(36)
end
