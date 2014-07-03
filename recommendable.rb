require 'pg'
require 'active_record'
require 'recommendable'
load 'mylib.rb'

#
# Setup ActiveRecord
#
ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  :database => 'freelogue',
)

#
# Define an ActiveRecord classes
#
class Content < ActiveRecord::Base
  include Recommendable::Ratable
  attr_accessor :id, :content
end

class Account < ActiveRecord::Base
  include Recommendable::Rater
  recommends :content
  attr_accessor :id, :name, :email
end

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
  #config.orm = :redis
  #config.ratable_classes = []
  #config.ratable_classes.push :Content
  print "orm             = '", config.orm, "'\n"
  print "ratable_classes = '", config.ratable_classes, "'\n"
  print "user_class      = '", config.user_class, "'\n"
  print "redis           = '", config.redis, "'\n"
end


me  = Account.new(:id => 69, :name => "brianf", :email => "brian@gmail.com")
you = Account.new(:id => 70, :name => "debra", :email => "debra@gmail.com")
c1 = Content.new(:id => 1000, :content => "www.edu.org")
c2 = Content.new(:id => 1001, :content => "www.www.www")


me.like(c1)
me.like(c2)
you.like(c2)

print "me #{me.id} likes c1 :", me.likes?(c1), "\n"
print "me    likes c2 :", me.likes?(c2), "\n"
print "you #{you.id} likes c1:", you.likes?(c1), "\n"
print "you    likes c2:", you.likes?(c2), "\n"

updaterMe = Recommendable::Workers::DelayedJob.new(me.id)
print "updateMe: ", updaterMe.perform, "\n"

updaterYou = Recommendable::Workers::DelayedJob.new(you.id)
print "updateYou: ", updaterYou.perform, "\n"

print "resque.work me : ", Recommendable::Workers::Resque.perform(me.id), "\n"
print "resque.work you: ", Recommendable::Workers::Resque.perform(you.id), "\n"

puts Recommendable::Helpers::Calculations.update_recommendations_for(me.id);
puts Recommendable::Helpers::Calculations.update_recommendations_for(you.id);
print "Similarities between me you: ", Recommendable::Helpers::Calculations.similarity_between(me.id, you.id), "\n"
print "Similarities between you me: ", Recommendable::Helpers::Calculations.similarity_between(you.id, me.id), "\n"
puts Recommendable::Helpers::Calculations.update_similarities_for(me.id);
puts Recommendable::Helpers::Calculations.update_similarities_for(you.id);

print "\nmy likes    : ",  me.liked_content_ids

print "\nyou likes   : ", you.liked_content_ids

STDOUT.flush
print "\nwe like     : ", me.likes_in_common_with(you)

print "\nc1 likes by : ", c1.liked_by().length

print "\nc2 likes by : ", c2.liked_by.length

#puts MyLib.dumpRedis
