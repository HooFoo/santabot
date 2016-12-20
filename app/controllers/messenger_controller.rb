class MessengerController

  def webhook
    Rails.logger.debug params.inspect
    # #logic here
    # if params['hub.mode'] == 'subscribe' && params['hub.verify_token'] == Messenger.config.verify_token
    #   render text: params['hub.challenge'], status: 200
    # else
    # end
    render nothing: true, status: 200

  end
end