require "./spec_helper"

describe MartenRedisSession::Store do
  before_each do
    get_redis_client.flushdb
  end

  describe "#create" do
    it "creates a new session entry without data" do
      store = MartenRedisSession::Store.new(nil)
      store.create

      client = get_redis_client
      client.get(store.session_key.to_s).should eq "{}"
    end

    it "creates a new session entry with the right TTL" do
      store = MartenRedisSession::Store.new(nil)
      store.create

      client = get_redis_client
      client.get(store.session_key.to_s).should eq "{}"
      client.ttl(store.session_key.to_s).should eq(
        Time::Span.new(seconds: Marten.settings.sessions.cookie_max_age).total_seconds.to_i
      )
    end

    it "properly sets a new session key" do
      store = MartenRedisSession::Store.new(nil)
      store.create

      store.session_key.not_nil!.size.should eq 32

      client = get_redis_client
      client.get(store.session_key.to_s).should eq "{}"
    end

    it "marks the store as modified" do
      store = MartenRedisSession::Store.new(nil)
      store.create

      store.modified?.should be_true
    end

    it "makes use of the configured namespace" do
      Marten.settings.redis_session.namespace = "ns"

      store = MartenRedisSession::Store.new(nil)
      store.create

      client = get_redis_client
      client.get("ns:#{store.session_key}").should eq "{}"
      client.ttl("ns:#{store.session_key}").should eq(
        Time::Span.new(seconds: Marten.settings.sessions.cookie_max_age).total_seconds.to_i
      )
    ensure
      Marten.settings.redis_session.namespace = nil
    end
  end

  describe "#flush" do
    it "destroys the entry associated with the store session key if it exists" do
      client = get_redis_client
      client.set("testkey", %{{"foo": "bar"}}, Time::Span.new(hours: 48).total_seconds.to_i)

      store = MartenRedisSession::Store.new("testkey")
      store.flush

      client.get("testkey").should be_nil
    end

    it "only destroys the entry associated with the store session key and does not impact other keys" do
      client = get_redis_client
      client.set("testkey", %{{"foo": "bar"}}, Time::Span.new(hours: 48).total_seconds.to_i)
      client.set("otherkey", %{{"test": "xyz"}}, Time::Span.new(hours: 48).total_seconds.to_i)

      store = MartenRedisSession::Store.new("testkey")
      store.flush

      client.get("testkey").should be_nil
      client.get("otherkey").should eq %{{"test": "xyz"}}
    end

    it "completes successfully if no entry exists for the store session key" do
      client = get_redis_client
      client.set("otherkey", %{{"foo": "bar"}}, Time::Span.new(hours: 48).total_seconds.to_i)

      store = MartenRedisSession::Store.new("testkey")
      store.flush

      client.get("otherkey").should eq %{{"foo": "bar"}}
    end

    it "marks the store as modified" do
      client = get_redis_client
      client.set("testkey", %{{"foo": "bar"}}, Time::Span.new(hours: 48).total_seconds.to_i)

      store = MartenRedisSession::Store.new("testkey")
      store.flush

      store.modified?.should be_true
    end

    it "resets the store session key" do
      store = MartenRedisSession::Store.new("testkey")
      store.flush

      store.session_key.should be_nil
    end

    it "resets the store session hash" do
      client = get_redis_client
      client.set("testkey", %{{"foo": "bar"}}, Time::Span.new(hours: 48).total_seconds.to_i)

      store = MartenRedisSession::Store.new("testkey")
      store.flush

      store.empty?.should be_true
      store["foo"]?.should be_nil
    end

    it "makes use of the configured namespace" do
      Marten.settings.redis_session.namespace = "ns"

      client = get_redis_client
      client.set("ns:testkey", %{{"foo": "bar"}}, Time::Span.new(hours: 48).total_seconds.to_i)

      store = MartenRedisSession::Store.new("testkey")
      store.flush

      client.get("ns:testkey").should be_nil
    ensure
      Marten.settings.redis_session.namespace = nil
    end
  end

  describe "#load" do
    it "retrieves the session data from Redis and loads the session hash from it" do
      client = get_redis_client
      client.set("testkey", %{{"foo": "bar"}}, Time::Span.new(hours: 48).total_seconds.to_i)

      store = MartenRedisSession::Store.new("testkey")
      store.load

      store["foo"].should eq "bar"
    end

    it "does not load the session hash if the session data is expired" do
      client = get_redis_client
      client.set("testkey", %{{"foo": "bar"}}, 1)

      sleep 1.5

      store = MartenRedisSession::Store.new("testkey")
      store.load

      store.size.should eq 0
      store["foo"]?.should be_nil
    end

    it "does not load the session hash if the session data does not exist" do
      store = MartenRedisSession::Store.new("testkey")
      store.load

      store.size.should eq 0
    end

    it "resets the session key if the session entry cannot be loaded because it is expired" do
      client = get_redis_client
      client.set("testkey", %{{"foo": "bar"}}, 1)

      sleep 1.5

      store = MartenRedisSession::Store.new("testkey")
      store.load

      store.session_key.should_not eq "testkey"
    end

    it "resets the session key if the store was initialized without a session key" do
      store = MartenRedisSession::Store.new(nil)
      store.load

      store.session_key.should_not be_nil
    end

    it "marks the store as modified if it was initialized without a session key" do
      store = MartenRedisSession::Store.new(nil)
      store.load

      store.modified?.should be_true
    end

    it "makes use of the configured namespace" do
      Marten.settings.redis_session.namespace = "ns"

      client = get_redis_client
      client.set("ns:testkey", %{{"foo": "bar"}}, Time::Span.new(hours: 48).total_seconds.to_i)

      store = MartenRedisSession::Store.new("testkey")
      store.load

      store["foo"].should eq "bar"
    ensure
      Marten.settings.redis_session.namespace = nil
    end
  end

  describe "#save" do
    it "persists the session data as expected if no entry was created before" do
      store = MartenRedisSession::Store.new(nil)

      store["foo"] = "bar"
      store.save

      client = get_redis_client
      client.get(store.session_key.to_s).should eq({"foo" => "bar"}.to_json)
      client.ttl(store.session_key.to_s).should eq(
        Time::Span.new(seconds: Marten.settings.sessions.cookie_max_age).total_seconds.to_i
      )
    end

    it "persists the session as expected if no entry was created before and the session hash is empty" do
      store = MartenRedisSession::Store.new(nil)

      store.save

      client = get_redis_client
      client.get(store.session_key.to_s).should eq "{}"
      client.ttl(store.session_key.to_s).should eq(
        Time::Span.new(seconds: Marten.settings.sessions.cookie_max_age).total_seconds.to_i
      )
    end

    it "persists the session data as expected if an entry was created before and updates the expiry time" do
      client = get_redis_client
      client.set("testkey", %{{"foo": "bar"}}, Time::Span.new(hours: 48).total_seconds.to_i)

      store = MartenRedisSession::Store.new("testkey")

      store["test"] = "xyz"
      store.save

      client.get("testkey").should eq({"foo" => "bar", "test" => "xyz"}.to_json)
      client.ttl("testkey").should eq(
        Time::Span.new(seconds: Marten.settings.sessions.cookie_max_age).total_seconds.to_i
      )
    end

    it "makes use of the configured namespace" do
      Marten.settings.redis_session.namespace = "ns"

      store = MartenRedisSession::Store.new(nil)

      store["foo"] = "bar"
      store.save

      client = get_redis_client
      client.get("ns:#{store.session_key}").should eq({"foo" => "bar"}.to_json)
      client.ttl("ns:#{store.session_key}").should eq(
        Time::Span.new(seconds: Marten.settings.sessions.cookie_max_age).total_seconds.to_i
      )
    ensure
      Marten.settings.redis_session.namespace = nil
    end
  end
end
