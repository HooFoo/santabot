require 'telegram/bot'
require 'require_all'
require 'yaml'
require 'hashie'
require 'logger'
require 'facebook/messenger'
require 'redis'
require 'savon'
require 'httparty'


require_all 'config'
require_all 'model'
require_all 'TGBot'
require_all 'FBBot'
require_all 'utils'

# Keep data for the current month only
LOG = Logger.new(Object.const_get(Config::App.app.logging.to))#'this_month.log', 'monthly')
LOG.level = Object.const_get("Logger::#{Config::App.app.logging.level}")


tbot = TGBot.new
tbot.start
