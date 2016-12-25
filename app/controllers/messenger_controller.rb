class MessengerController

  @@bot = TGBot.new

  def webhook
    Rails.logger.debug params.inspect
    @@bot.update(params)
    render nothing: true, status: 200
  end
end