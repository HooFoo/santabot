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
          self.reply message,
                     ReplicaService.get_replica_for_state(history.state, message.text),
                     self.initial_keyboard_part_two

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
    begin
      chat_id = postback.sender[:id]
      history = Dialog.new(chat_id,RedisStorage.get_user_session(chat_id))
      history.state = postback.payload
      self.reply postback,
                 ReplicaService.get_replica_for_state(history.state,'dummy')
      RedisStorage.update_user_session chat_id, history
    rescue ApiException => ex
      self.reply postback, ex.message
    rescue => ex
      Rails.logger.error "Facebook bot  error: #{ex.message}"
      self.reply postback, 'Упс, у меня что-то сломалось. Попробуйте написать что-то другое.'
    end
  end

  def self.reply message, text=nil , keyboard = nil
    if text.nil?
      message.reply(text: text)
    else
      message.reply(attachment: keyboard)
    end
  end

  def self.initial_keyboard
    {
        type: 'template',
        payload: {
            template_type: 'button',
            text: 'Привет, я - Санта бот. Я помогу тебе выбрать подарок. Ты можешь выбрать что-то отсюда',
            buttons: [
                { type: 'postback', title: 'Рейтинг подарков 🔄', payload: 'rating' },
                { type: 'postback', title: 'Скидка от Санты  💰', payload: 'discount' },
            ]
        }
    }
  end

  def self.initial_keyboard_part_two
    {
        type: 'template',
        payload: {
            template_type: 'button',
            text: 'Или мы можем обсудить твой подарок',
            buttons: [
                { type: 'postback', title: 'Чат с сантой  💬', payload: 'chat' },
                { type: 'postback', title: 'Письмо пожелание ✉', payload: 'letter' },
                { type: 'postback', title: 'Групповой чат 👨‍👩‍👧‍👧', payload: 'groupchat' },
            ]
        }
    }
  end
end