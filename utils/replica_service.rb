class ReplicaService

  def self.get_replica_for_state(state, name)
    self.send state, name
  end

  private

  def self.hello(name)
    [
        "Хо хо хо! Привет, #{name} меня зовут Дед Мороз бот, меня создали для примера и дальнейшего расширения функционала. Сейчас я задам тебе пару вопросов.",
        "Привет, #{name}! Я как раз ждал тебя! Меня зовут Дед Мороз бот, и я уверен что ты пришел ко мне за своим подарком. Я задам тебе несколько наводящих вопросов."
    ].sample
  end

  def self.who(name)
    [
        'Кому ты хочешь сделать подарок?',
        'Ты готовишь подарок для?'
    ].sample
  end

  def self.hobby(name)
    morphed = Morpher.new name
    [
      "#{morphed.singular :И} на досуге любит?",
      "Что любит делать  #{morphed.singular :И}?",
      "Какое хобби у #{morphed.singular :Р}?"
    ].sample
  end

  def self.tool(name)
    [
      "Что нужно для этого?",
      "Чем он/она обычно это делает?"
    ].sample
  end

  def self.finished(name)
    morphed = Morpher.new name
    [
        "Думаю #{morphed.singular :Д} нужно это: ",
        "Наверное #{morphed.singular :Д} нужно это: "
    ].sample
  end
end