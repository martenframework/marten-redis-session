module MartenRedisSession
  # Redis session store.
  class Store < Marten::HTTP::Session::Store::Base
    @client : Redis::Client? = nil

    def create : Nil
      @session_key = gen_session_key
      persist_session_data

      @modified = true
    end

    def flush : Nil
      client.del(client_key(@session_key.not_nil!)) unless @session_key.nil?

      @session_hash = SessionHash.new
      @session_key = nil
      @modified = true
    end

    def load : SessionHash
      data = client.get(client_key(@session_key.not_nil!))
      SessionHash.from_json(data.not_nil!)
    rescue NilAssertionError
      create
      SessionHash.new
    end

    def save : Nil
      @modified = true
      persist_session_data(session_hash)
    end

    private def client : Redis::Client
      @client = if (uri = Marten.settings.redis_session.uri).nil?
                  Redis::Client.new
                else
                  Redis::Client.new(URI.parse(uri))
                end
    end

    private def client_key(key : String) : String
      if Marten.settings.redis_session.namespace
        "#{Marten.settings.redis_session.namespace}:#{key}"
      else
        key
      end
    end

    private def gen_session_key
      loop do
        new_session_key = Random::Secure.random_bytes(16).hexstring
        return new_session_key if client.exists(client_key(new_session_key)) == 0
      end
    end

    private def persist_session_data(data = nil)
      data = data.nil? ? "{}" : data.to_json
      expires_in = Time::Span.new(seconds: Marten.settings.sessions.cookie_max_age)

      client.set(client_key(@session_key.not_nil!), data, expires_in.total_seconds.to_i)
    end
  end
end
