ENV["MARTEN_ENV"] = "test"

require "spec"
require "timecop"

require "marten"
require "marten/spec"

require "../src/marten_redis_session"

require "./test_project"

def get_redis_client
  if (uri = Marten.settings.redis_session.uri).nil?
    Redis::Client.new
  else
    Redis::Client.new(URI.parse(uri))
  end
end
