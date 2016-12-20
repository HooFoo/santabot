class FBBot
  include Facebook::Messenger

  Bot.on :message do |message|
    begin
      chat_id = message.sender[:id]
      history = Dialog.new(chat_id,RedisStorage.get_user_session(chat_id))
      case history.state
        when 'chat'
          history.state = 'chat_two'
          self.reply message,
                     ReplicaService.get_replica_for_state(history.state, message.text)
        when 'chat_two'
          history.state = 'chat_three'
          self.reply message,
                     ReplicaService.get_replica_for_state(history.state, message.text)
        when 'letter'
          history.state = 'letter_two'
          self.reply message,
                     ReplicaService.get_replica_for_state(history.state, message.text)
        else
          history.state = 'unknown'
          self.reply message,
                     ReplicaService.get_replica_for_state(history.state, message.text),
                     self.initial_keyboard

      end
      RedisStorage.update_user_session chat_id, history
    rescue ApiException => ex
      self.reply message, ex.message
    rescue => ex
      Rails.logger.error "Facebook bot  error: #{ex.message}"
      self.reply message, 'Упс, у меня что-то сломалось. Попробуйте написать что-то другое.'
    end
  end

  Bot.on :postback do |postback|
    postback.sender    # => { 'id' => '1008372609250235' }
    postback.recipient # => { 'id' => '2015573629214912' }
    postback.sent_at   # => 2016-04-22 21:30:36 +0200
    postback.payload   # => 'EXTERMINATE'

    if postback.payload == 'EXTERMINATE'
      puts "Human #{postback.recipient} marked for extermination"
    end
  end

  def self.reply message, text, keyboard = nil
    message.reply(text: text, attachment: keyboard)
  end

  def self.initial_keyboard
    {
        type: 'template',
        payload: {
            template_type: 'button',
            text: 'Привет, я - Санта бот. Я помогу тебе выбрать подарок.',
            buttons: [
                { type: 'postback', title: 'Yes', payload: 'HARMLESS' },
                { type: 'postback', title: 'No', payload: 'EXTERMINATE' }
            ]
        }
    }
  end
end