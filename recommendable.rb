require 'pg'
require 'active_record'
require 'recommendable'
load 'mylib.rb'

Recommendable.configure do |config|
  # Recommendable's connection to Redis
  config.redis = Redis.new(:host => 'localhost', :port => 6379, :db => 0)
  # A prefix for all keys Recommendable uses
  config.redis_namespace = :recommendable
  # Whether or not to automatically enqueue users to have their recommendations  refreshed after they like/dislike an item
  config.auto_enqueue = true
  # The name of the queue that background jobs will be placed in  BF: Recommendable.config.queue_name has been deprecated. Jobs will always be placed in a queue named 'recommendable'.
  #config.queue_name = :recommendable
  # The number of nearest neighbors (k-NN) to check when updating
  # recommendations for a user. Set to `nil` if you want to check all
  # other users as opposed to a subset of the nearest ones.
  config.nearest_neighbors = nil
  config.orm = :activerecord
  #print "orm             = '", config.orm, "'\n"
  #print "ratable_classes = '", config.ratable_classes, "'\n"
  #print "user_class      = '", config.user_class, "'\n"
end

MyLib.dumpRedis

