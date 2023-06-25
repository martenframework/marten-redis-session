require "redis"

require "./marten_redis_session/settings"
require "./marten_redis_session/store"

module MartenRedisSession
  VERSION = "0.1.0.dev"
end

# Registers the Redis session store.
Marten::HTTP::Session::Store.register("redis", MartenRedisSession::Store)
