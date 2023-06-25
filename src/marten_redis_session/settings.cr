module MartenRedisSession
  # Holds Redis session-related settings.
  class Settings < Marten::Conf::Settings
    namespace :redis_session

    @namespace : String? = nil
    @uri : String? = nil

    # Returns the namespace to use for Redis keys that map to session entries.
    getter namespace

    # Returns the URI of the Redis server to connect to.
    getter uri

    # Allows to set the namespace to use for Redis keys that map to session entries.
    def namespace=(namespace : Nil | String | Symbol)
      @namespace = namespace.try(&.to_s)
    end

    # Allows to set the URI of the Redis server to connect to.
    #
    # Unless specified, the client will attempt to connect to Redis on `localhost` and port `6379`.
    def uri=(uri : Nil | String | Symbol)
      @uri = uri.try(&.to_s)
    end
  end
end
