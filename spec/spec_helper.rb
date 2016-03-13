require 'rubygems'
require 'bundler'
require 'rspec'
require 'delayed-method'
require 'redis_test'
require 'byebug'

RSpec.configure do |config|
  config.before(:suite) do
    RedisTest.start
    Resque.redis = "#{RedisTest.server_url}/resque"
  end

  config.after(:each) do
    RedisTest.clear
    # notice that will flush the Redis db, so it's less
    # desirable to put that in a config.before(:each) since it may clean any
    # data that you try to put in redis prior to that
  end

  config.after(:suite) do
    RedisTest.stop
  end
end
