require "./spec_helper"

describe MartenRedisSession do
  it "registers the Redis session store" do
    Marten::HTTP::Session::Store.get("redis").should eq MartenRedisSession::Store
  end
end
