# Marten Redis Session

[![CI](https://github.com/martenframework/marten-redis-session/workflows/Specs/badge.svg)](https://github.com/martenframework/marten-redis-session/actions)
[![CI](https://github.com/martenframework/marten-redis-session/workflows/QA/badge.svg)](https://github.com/martenframework/marten-redis-session/actions)

**Marten Redis Session** provides a [Redis](https://redis.io) [session store](https://martenframework.com/docs/handlers-and-http/sessions#session-stores) for the Marten web framework.

## Installation

Simply add the following entry to your project's `shard.yml`:

```yaml
dependencies:
  marten_redis_session:
    github: martenframework/marten-redis-session
```

And run `shards install` afterward.

## Configuration

First, add the following requirement to your project's `src/project.cr` file:

```crystal
require "marten_redis_session"
```

Then you can configure your project to use the Redis session store by ensuring that the [`sessions.store`](https://martenframework.com/docs/development/reference/settings#store) setting is set to `:redis`:

```crystal
Marten.configure do |config|
  config.sessions.store = :redis
end
```

_Congrats! You’re in!_ From now on, your session data will be persisted in Redis.

It should be noted that by default the Redis session store will attempt to connect to Redis on `localhost` and port `6379`. This can be changed by setting a different URI through the use of the `redis_session.uri` setting:

```crystal
Marten.configure do |config|
  config.redis_session.uri = "redis:///"
end
```

It is also worth mentioning that you can leverage the `redis_session.namespace` setting to configure a "namespace" for the Redis keys that will be used to persist session data. This can be useful if your Redis instance is shared for various purposes and you need to prevent conflicts between session data keys and other Redis keys. For example:

```crystal
Marten.configure do |config|
  config.redis_session.namespace = "sessions"
end
```

## Authors

Morgan Aubert ([@ellmetha](https://github.com/ellmetha)) and 
[contributors](https://github.com/martenframework/marten-redis-session/contributors).

## License

MIT. See ``LICENSE`` for more details.
