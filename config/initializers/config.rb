module Config
  Telegram = Hashie::Mash.new YAML.load(File.open('config/telegram.yml'))
  Facebook = Hashie::Mash.new YAML.load(File.open('config/facebook.yml'))
  App = Hashie::Mash.new YAML.load(File.open('config/application.yml'))
end

