require 'redis'
require 'recommendable'

Recommendable.configure do |config|
  # Recommendable's connection to Redis
  config.redis = Redis.new(:host => 'localhost', :port => 6379, :db => 0)
  puts config.redis

  # A prefix for all keys Recommendable uses
  config.redis_namespace = :recommendable
  puts config.redis_namespace

  # Whether or not to automatically enqueue users to have their recommendations
  # refreshed after they like/dislike an item
  config.auto_enqueue = true
  puts config.auto_enqueue

  # The name of the queue that background jobs will be placed in
  config.queue_name = :recommendable
  puts config.queue_name

  # The number of nearest neighbors (k-NN) to check when updating
  # recommendations for a user. Set to `nil` if you want to check all
  # other users as opposed to a subset of the nearest ones.
  config.nearest_neighbors = nil
  puts config.nearest_neighbors
end
