class TGBot

  Token = Config::Telegram.env.token

  def initialize
    LOG.info 'Bot started'
    @client = Telegram::Bot::Client
  end

  def start
    loop do
      begin
        @client.run(Token) do |bot|
          @bot = bot
          bot.listen do |message|
            process message
          end
        end
      rescue Exception => e
        LOG.error e
        sleep 5000
      end
    end
  end

  private

  def process(msg)
    LOG.debug msg.to_yaml
    case msg
      when Telegram::Bot::Types::InlineQuery
        process_inline msg
      when Telegram::Bot::Types::Message
        process_message msg
      when Telegram::Bot::Types::CallbackQuery
        process_cb msg
    end
  end

  def process_inline(query)
=begin
    location = query.location
    if location.nil?
      url_button = Telegram::Bot::Types::InlineKeyboardButton.new text: 'Попробовать онлайн',
                                                                  url: 'http://rasp.orgp.spb.ru/'
      message = Telegram::Bot::Types::InputTextMessageContent.new message_text: 'Пожалуйста, разрешите доступ к вашему местоположению',
                                                                  parse_mode: 'Markdown'
      keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new inline_keyboard: [[url_button]]
      result = Telegram::Bot::Types::InlineQueryResultArticle.new id: rand,
                                                                  title: 'Разрешите местоположение',
                                                                  reply_markup: keyboard,
                                                                  input_message_content: message
    else
      text = RaspApi.get_stops(location)
      message = Telegram::Bot::Types::InputTextMessageContent.new message_text: text
      result = Telegram::Bot::Types::InlineQueryResultArticle.new id: rand,
                                                                  url: text,
                                                                  title: 'Ближайшие остановки',
                                                                  input_message_content: message
    end
    @bot.api.answer_inline_query inline_query_id: query.id,
                                 results: [result]
=end
  end

  def process_message(message)
    begin
      chat_id = message.chat.id
      history = Dialog.new(message.chat.id,RedisStorage.get_user_session(chat_id))
      case message.text
        when '/start'
          history.clear
          send_reply chat_id,
                     ReplicaService.get_replica_for_state(history.state, message.from.first_name),
                     initial_keyboard
        when 'Чат с сантой  💬'
          history.state = 'chat'
          send_reply chat_id,
                     ReplicaService.get_replica_for_state(history.state, message.from.first_name)
        when 'Рейтинг подарков 🔄'
          history.state = 'rating'
          send_reply chat_id,
                     ReplicaService.get_replica_for_state(history.state, message.from.first_name)
        when 'Скидка от Санты  💰'
          history.state = 'discount'
          send_reply chat_id,
                     ReplicaService.get_replica_for_state(history.state, message.from.first_name)
        when 'Письмо пожелание ✉️'
          history.state = 'letter'
          send_reply chat_id,
                     ReplicaService.get_replica_for_state(history.state, message.from.first_name)
        when "Групповой чат 👨‍👩‍👧‍👧" #only doublequoted
          history.state = 'groupchat'
          send_reply chat_id,
                     ReplicaService.get_replica_for_state(history.state, message.from.first_name)
        else
          case history.state
            when 'chat'
              history.state = 'chat_two'
              send_reply chat_id,
                         ReplicaService.get_replica_for_state(history.state, message.text)
            when 'chat_two'
              history.state = 'chat_three'
              send_reply chat_id,
                         ReplicaService.get_replica_for_state(history.state, message.text)
            when 'letter'
              history.state = 'letter_two'
              send_reply chat_id,
                         ReplicaService.get_replica_for_state(history.state, message.text)
            else
              history.state = 'unknown'
              send_reply chat_id,
                         ReplicaService.get_replica_for_state(history.state, message.from.first_name),
                         initial_keyboard

          end
      end
      # if ['/start'].include? message.text || history.state == 'finished'
      #
      # elsif history.state != 'finished'
      #
      #   if history.state != 'finished'
      #     send_reply chat_id, ReplicaService.get_replica_for_state(history.state, history.answers[:who])
      #   else
      #     more = Telegram::Bot::Types::KeyboardButton.new text: "Я хочу еще с тобой поговорить!"
      #     markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new keyboard:[[more]],
      #                                                            one_time_keyboard: true,
      #                                                            resize_keyboard: true
      #     link = QueryService.generate_link(history.answers[:who],history.answers[:hobby],history.answers[:tool])
      #     text = "#{ReplicaService.get_replica_for_state(history.state, history.answers[:who])} #{link}"
      #     send_reply chat_id, text, markup
      #   end
      # end
      RedisStorage.update_user_session chat_id, history
    rescue ApiException => ex
      send_reply message.chat.id, ex.message
    rescue => ex
      LOG.error "Telegram bot  error: #{ex.message}"
      send_reply message.chat.id, 'Упс, у меня что-то сломалось. Попробуйте написать что-то другое.'
    end
  end

  def process_cb (msg)

  end

  def send_reply(chat_id, text, keyboard=nil)
    @bot.api.send_message chat_id: chat_id,
                          reply_markup: keyboard,
                          text: text
  end


  def send_link id,uname,name,link
    @bot.api.send_message chat_id: id,
                          reply_markup: markup,
                          text: "Замечательно, #{uname}! Вот здесь ты свожешь получить свой #{name}: [#{link}]",
                          parse_mode: 'Markdown'
  end

  def initial_keyboard
    chat = Telegram::Bot::Types::KeyboardButton.new text: "Чат с сантой  💬"
    rating = Telegram::Bot::Types::KeyboardButton.new text: "Рейтинг подарков 🔄"
    discount = Telegram::Bot::Types::KeyboardButton.new text: "Скидка от Санты  💰"
    letter = Telegram::Bot::Types::KeyboardButton.new text: "Письмо пожелание ✉️"
    group = Telegram::Bot::Types::KeyboardButton.new text: "Групповой чат 👨‍👩‍👧‍👧"
    Telegram::Bot::Types::ReplyKeyboardMarkup.new keyboard:[[chat,rating],[discount,letter],[group]],
                                                           resize_keyboard: true
  end

end