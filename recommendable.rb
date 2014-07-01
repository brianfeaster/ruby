require 'recommendable'

class Event
 include Recommendable::Ratable
 def self.classify
 end
 def classify
 end
end
link = Event.new
Event.make_recommendable!

class User
 include Recommendable::Rater
 def self.classify
 end
 def classify
 end
end
jon = User.new

puts "---------------"
Recommendable.redis
puts "---------------"

User.recommends(Event)



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

  print "orm             = '", config.orm, "'\n"
  print "ratable_classes = '", config.ratable_classes, "'\n"
  print "user_class      = '", config.user_class, "'\n"
end


r = Redis.new
r.keys('*').each do |x|
  case r.type(x)
    when 'string'
      val = r.get(x);
      print x, " = ", val, "\n"
    when 'list'
      val = r.lrange(x, 0, -1)
      print x, " |= ", val, "\n"
    when 'hash'
      val = r.hkeys(x)
      print x, " @= ", val, "\n"
  end # case r.type
end # r.keys


