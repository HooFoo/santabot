class RedisStorage
  @@redis = Redis.new

  def self.get_user_session(id)
    json = @@redis.get(id)
    json.nil? ? json : Hashie::Mash.new(JSON.parse(json))
  end

  def self.update_user_session(id, dialog)
    @@redis.set id, dialog.to_json
  end
end