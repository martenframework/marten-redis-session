require "./spec_helper"

describe MartenRedisSession::Settings do
  describe "#namespace" do
    it "returns nil by default" do
      settings = MartenRedisSession::Settings.new

      settings.namespace.should be_nil
    end

    it "returns the configured namespace" do
      settings = MartenRedisSession::Settings.new
      settings.namespace = "ns"

      settings.namespace.should eq "ns"
    end
  end

  describe "#namespace=" do
    it "allows to set the namespace from a string value" do
      settings = MartenRedisSession::Settings.new
      settings.namespace = "ns"

      settings.namespace.should eq "ns"
    end

    it "allows to set the namespace from a symbol value" do
      settings = MartenRedisSession::Settings.new
      settings.namespace = :ns

      settings.namespace.should eq "ns"
    end

    it "allows to reset the namespace" do
      settings = MartenRedisSession::Settings.new
      settings.namespace = "ns"
      settings.namespace = nil

      settings.namespace.should be_nil
    end
  end

  describe "#uri" do
    it "returns nil by default" do
      settings = MartenRedisSession::Settings.new

      settings.uri.should be_nil
    end

    it "returns the configured namespace" do
      settings = MartenRedisSession::Settings.new
      settings.uri = "redis:///"

      settings.uri.should eq "redis:///"
    end
  end

  describe "#uri=" do
    it "allows to set the Redis URI from a string value" do
      settings = MartenRedisSession::Settings.new
      settings.uri = "redis:///"

      settings.uri.should eq "redis:///"
    end

    it "allows to set the Redis URI from a symbol value" do
      settings = MartenRedisSession::Settings.new
      settings.uri = :"redis:///"

      settings.uri.should eq "redis:///"
    end

    it "allows to reset the Redis URI" do
      settings = MartenRedisSession::Settings.new
      settings.uri = "redis:///"
      settings.uri = nil

      settings.uri.should be_nil
    end
  end
end
