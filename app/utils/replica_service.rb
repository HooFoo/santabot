class ReplicaService
  include HTTParty
  base_uri 'http://vpdev.tk/'

  def self.get_replica_for_state(state, message)
    self.send state, message
  end

  private

  def self.hello(name)
    [
        "Хо хо хо! Привет, #{name} меня зовут Дед Мороз бот. Нажми на одну из кнопок, чтобы я узнал что ты хочешь в подарок.",
        "Привет, #{name}! Я как раз ждал тебя! Меня зовут Дед Мороз бот, и я уверен что ты пришел ко мне за своим подарком. Давай сделаем это!"
    ].sample
  end

  def self.rating(name)
    do_get('rating')
  end

  def self.discount(name)
    do_get('discount')
  end

  def self.groupchat(name)
    do_get('groupchat')
  end

  def self.chat(message)
    do_get('chat', step: 1)
  end

  def self.chat_two(message)
    do_get('chat', step: 2, message: message)
  end

  def self.chat_three(message)
    do_get('chat', step: 3, message: message)
  end

  def self.letter(message)
    do_get('letter', step: 1)
  end

  def self.letter_two(message)
    do_get('letter', step: 2, message: message)
  end

  def self.unknown(message)
    "Дедушка тебя не понял. Попрбуй нажать на кнопку и повторить попытку."
  end

  def self.do_get action, params = {}
    query = {action: action, sc: 'telegram'}.merge(params)
    res = self.get('/santa/api.php', query: query)
    json = JSON.parse(res)
    if json['error'] == 0
      json['message']
    else
      raise ApiException.new json['message']
    end
  end
end