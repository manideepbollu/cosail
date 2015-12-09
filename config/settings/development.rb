# DO NOT SET SENSITIVE DATA HERE!
# USE ENVIRONMENT VARIABLES OR 'local.rb' INSTEAD

SimpleConfig.for :application do
  group :facebook do
    # NOTE: If you don't want to use 'FACEBOOK_APP_ID' as variable name,
    # edit 'assets/javascripts/fbjssdk.js.coffee' too
    set :namespace, ENV['FACEBOOK_NAMESPACE']
    set :app_id, '200689230270283'
    set :secret, '129124a3bfc04039a2e3eabecd63852f'
  end
end
