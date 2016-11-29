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

  def process msg
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

  def process_inline query
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

  def process_message message
    if ['/start', 'Я хочу еще с тобой поговорить!'].include? message.text
        @bot.api.send_message chat_id: message.chat.id,
                              text: random_hello(message.from.first_name)
    elsif message.text =~ /Да, я хочу [\w\d\s]+ !/i
      name = message.text.match(/Да, я хочу ([\w\d\s]+) !/i)[1]
      send_link message.chat.id, message.from.first_name, name,ShopApi.item_link(name)
    elsif ['Нет'].include? message.text
      process_question message.chat.id
    else
      process_question message.chat.id
    end
  end

  def process_cb msg

  end

  def process_question id
    repl = random_reply
    yes = Telegram::Bot::Types::KeyboardButton.new text: "Да, я хочу #{repl[:name]} !"
    no = Telegram::Bot::Types::KeyboardButton.new text: "Нет"
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new keyboard:[[yes,no]]
    @bot.api.send_message chat_id: id,
                          reply_markup: markup,
                          text: repl[:text]
  end


  def send_link id,uname,name,link
    more = Telegram::Bot::Types::KeyboardButton.new text: "Я хочу еще с тобой поговорить!"
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new keyboard:[[more]]
    @bot.api.send_message chat_id: id,
                          reply_markup: markup,
                          text: "Замечательно, #{uname}! Вот здесь ты свожешь получить свой #{name}: [#{link}]",
                          parse_mode: 'Markdown'
  end

  def random_reply
    name = ShopApi.get_random_item_name
    text = ["Пока летел олени растрясли повозку и я потерял твой подарок... Возможно вместо того, что ты просишь тебе подойдет #{name}?",
    "К сожалению эльфы затянули по срокам и то что ты ищешь я найти не могу... Возможно вместо того, что ты просишь тебе подойдет #{name}?"].sample
    {name: name,
    text: text}
  end

  def random_hello name
    ["Хо хо хо! Привет, #{name} меня зовут Дед Мороз бот, меня создали для примера и дальнейшего расширения функционала. Задай любой вопрос и я сгенерирую случайный товар!",
     "Привет, #{name}! Я как раз ждал тебя! Меня зовут Дед Мороз бот, и я уверен что ты пришел ко мне за своим подарком. Напиши мне, что же ты хочешь получить! Скорей!"].sample
  end
end