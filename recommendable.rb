require 'pg'
require 'active_record'
require 'recommendable'
load 'mylib.rb'

#
# Setup Redis
#
puts "** Recommendable.redis.flushall ****"
Recommendable.redis.flushall


#
# Setup ActiveRecord
#
puts "** ActiveRecord::Base.establish_connection ****"
ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  :database => 'freelogue',
)


#
# Define ActiveRecord classes
#
puts "** Create Content and Account classes ****"

class Content < ActiveRecord::Base
  self.primary_key = "id"
  #attr_accessor :id, :content
end

class Account < ActiveRecord::Base
  self.primary_key = "id"
  recommends :content
  #attr_accessor :id, :email, :name
end



Recommendable.configure do |config|
  # Recommendable's connection to Redis
  config.redis = Redis.new(:host => 'localhost', :port => 6379, :db => 0)
  # A prefix for all keys Recommendable uses
  config.redis_namespace = :recommendable
  # Whether or not to automatically enqueue users to have their recommendations  refreshed after they like/dislike an item
  config.auto_enqueue = true
  # The number of nearest neighbors (k-NN) to check when updating
  # recommendations for a user. Set to `nil` if you want to check all
  # other users as opposed to a subset of the nearest ones.
  config.nearest_neighbors = nil
  #print "orm             = '", config.orm, "'\n"
  #print "ratable_classes = '", config.ratable_classes, "'\n"
  #print "user_class      = '", config.user_class, "'\n"
  #print "redis           = '", config.redis, "'\n"
end

#
# Parse in the postgres DB
#
$conn = PG.connect(dbname: 'freelogue')


#
# {"userid"=>"43", "sharelist"=>"5 8 12 13 16 18 26 28 30 34 36 37 40 44 48 49 50 55 58 61 63 65 68 70 72 79 80 86 88 92 93 95 100"}
# {"userid"=>"8", "sharelist"=>"2 3 5 7 12 15 16 18 24 25 26 27 29 30 32 36 37 44 45 50 52 53 64 65 66 72 80 82 89 92 93 94 95 97 100"}
# ...
#
query = "select userid, string_agg(concat(contentid), ' ') as sharelist from usershare group by userid order by userid"
shares = $conn.exec(query)
#shares.each {|h| puts h}

#
#{"userid"=>"1"}{"userid"=>"2"}{"userid"=>"3"}{"userid"=>"4"}...
#
query = "SELECT id as userid from accounts"
accounts = $conn.exec(query)
#accounts.each {|u| print u}

#
#{"contentid"=>"1"}{"contentid"=>"2"}{"contentid"=>"3"}{"contentid"=>"4"}...
#
query = "SELECT id as contentid from contents"
contents = $conn.exec(query)
#contents.each {|c| print c}

#
# Tell recommendable what users like what content
#
shares.each {|h|
  me = Account.find(h['userid']); # me{id, email, name}
  h['sharelist'].split(' ').map {|c|
    content = Content.find(c) # content{id, content}
    me.like(content)
  }
  #print "\n", me.id, " likes: ", me.likes().map(&:id).join('.')
}


#
# Actors
#
me  = Account.find(1); # me{id, email, name}
you = Account.find(2); # me{id, email, name}
meId = me.id
youId = you.id


#
# COMPUTE ALL THE STATS
#
print "\n**** Updating Stats... ****"
Recommendable::Helpers::Calculations.update_similarities_for(meId)
Recommendable::Helpers::Calculations.update_recommendations_for(meId)

Recommendable::Helpers::Calculations.update_similarities_for(youId)
Recommendable::Helpers::Calculations.update_recommendations_for(youId)


#
# SHOW ALL THE STATS
#

def probToChar p
  case p
    when 0.0
      ' '
    when (0.0..0.1)
      '.'
    when (0.1..0.2)
      '_'
    when (0.2..0.3)
      '▁'
    when (0.3..0.4)
      '▂'
    when (0.4..0.5)
      '▃'
    when (0.5..0.6)
      '▄'
    when (0.6..0.7)
      '▅'
    when (0.7..0.8)
      '▆'
    when (0.8..0.9)
      '▇'
    when (0.9..0.98)
      '▉'
    when (0.98..100.0)
      '░'
  end
end
#print "[", (101.times.map{|p| probToChar(p/100.0)}.join), "]"

#
# Grid of users to likes
#
100.times {|uid|
  uid = uid + 1
  lme = Account.find(uid);
  print "\n#{uid} [", (100.times.map{|n|
    n=n+1
    if lme.likes?(Content.find(n))
      '*'
    elsif lme.dislikes?(Content.find(n))
      '-'
    else
      ' '
    end
  }.join), "]"
}

# Graph of my similarity to everyone else
100.times {|uid|
  uid = uid + 1
  print "\nSimilarity between #{uid} and: [", 100.times.map{|n| n=n+1; probToChar Recommendable::Helpers::Calculations.similarity_between(uid, n)}.join, "]"
}

print "\n\nme likes       : ",  me.liked_content_ids
print "\nyou likes        : ", you.liked_content_ids
print "\nyou liked_content: ", you.liked_content.map(&:id).join(' ')
print "\n\nme likes_in_common_with you:", me.likes_in_common_with(you).map(&:id).join(' ')
print "\nyou likes_in_common_with me:", you.likes_in_common_with(me).map(&:id).join(' ')

print "\n\nc1 liked by : ", Content.find(1).liked_by.map {|x| x.id}
print "\nc2 liked by : ", Content.find(2).liked_by.map {|x| x.id}


print "\n\nyou similar_raters: ",  you.similar_raters.map(&:id).join(' ')
print "\nme  similar_raters: ", me.similar_raters.map(&:id).join(' ')

print "\npredict_for you c1: ", Recommendable::Helpers::Calculations.predict_for(you.id, Content, c2.id)

MyLib.dumpRedis
