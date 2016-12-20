class ReplicaService
  include HTTParty
  base_uri 'http://vpdev.tk/'

  def self.get_replica_for_state(state, message, sc = 'telegram')
    self.send state, message, sc
  end

  private

  def self.hello(name, sc)
    [
        "Хо хо хо! Привет, #{name} меня зовут Дед Мороз бот. Нажми на одну из кнопок, чтобы я узнал что ты хочешь в подарок.",
        "Привет, #{name}! Я как раз ждал тебя! Меня зовут Дед Мороз бот, и я уверен что ты пришел ко мне за своим подарком. Давай сделаем это!"
    ].sample
  end

  def self.rating(name, sc)
    do_get('rating', sc: sc)
  end

  def self.discount(name, sc)
    do_get('discount', sc: sc)
  end

  def self.groupchat(name, sc)
    do_get('groupchat', sc: sc)
  end

  def self.chat(message, sc)
    do_get('chat', step: 1, sc: sc)
  end

  def self.chat_two(message, sc)
    do_get('chat', step: 2, message: message, sc: sc)
  end

  def self.chat_three(message, sc)
    do_get('chat', step: 3, message: message, sc: sc)
  end

  def self.letter(message, sc)
    do_get('letter', step: 1, sc: sc)
  end

  def self.letter_two(message, sc)
    do_get('letter', step: 2, message: message, sc: sc)
  end

  def self.unknown(message)
    "Дедушка тебя не понял. Попрбуй нажать на кнопку и повторить попытку."
  end

  def self.do_get action, params = {}
    query = {action: action}.merge(params)
    res = self.get('/santa/api.php', query: query)
    json = JSON.parse(res)
    if json['error'] == 0
      json['message']
    else
      raise ApiException.new json['message']
    end
  end
end