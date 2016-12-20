class FBBot
  include Facebook::Messenger

  Bot.on :message do |message|
    puts message.inspect
    message.reply(text: 'Hello, human!')
  end
end