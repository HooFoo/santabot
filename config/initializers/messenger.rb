Messenger.configure do |config|
  config.verify_token      = ENV['FB_VERIFY'] #will be used in webhook verifiction
  config.page_access_token = ENV['FB_MESSENGER']
end