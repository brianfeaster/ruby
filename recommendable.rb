require 'active_record'
require 'recommendable'
load 'mylib.rb'



## Define ActiveRecord classes
class Content < ActiveRecord::Base
  self.primary_key = "id"
  #attr_accessor :id, :content
end

class User < ActiveRecord::Base
  self.primary_key = "id"
  recommends :content
  #attr_accessor :id, :email, :name
end



module RecommendableFun
  class << self
    attr_accessor :conn, :shares, :kills, :userShareCount, :userKillCount
  end

  puts ActiveRecord::Base.establish_connection(:adapter => 'postgresql', :database => 'postgres') ## Connect to ActiveRecord ####

  puts @conn = ActiveRecord::Base.connection ## For directl SQL messages

  Recommendable.configure do |config|  ## Setup Recommendable gem ####
    config.redis = Redis.new(host:'redist1micro213mb.kvvtix.0001.usw2.cache.amazonaws.com', port:6379, db:0)
    config.auto_enqueue = true
    config.nearest_neighbors = nil
  end

  # Consider all users and their "shares" and "kills" in a sorted list
  #  {"user_id"=>"43", "contentlist"=>"5 8 12 13 16 18 26 28 30 34 36 37 40 44 48 49 50 55 58 61 63 65 68 70 72 79 80 86 88 92 93 95 100"}
  #  {"user_id"=>"8", "contentlist"=>"2 3 5 7 12 15 16 18 24 25 26 27 29 30 32 36 37 44 45 50 52 53 64 65 66 72 80 82 89 92 93 94 95 97 100"}
  #  ...
  @shares = conn.execute("select user_id, string_agg(concat(content_id), ' ' order by content_id) as contentlist from user_responses where response = TRUE group by user_id order by user_id")
  @kills = conn.execute("select user_id, string_agg(concat(content_id), ' ' order by content_id) as contentlist from user_responses where response = FALSE group by user_id order by user_id")
  @userShareCount= shares.count
  @userKillCount = kills.count
  print "\ncontentCount = ",   conn.execute('SELECT count (*) from contents')[0]['count']
  print "\nuserShareCount = ", userShareCount
  print "\nuserKillCount = ",  userKillCount

  def self.resetUserActions
    puts "\n****************************************************"
    puts   "**** Resetting the redis DB of all user actions ****"
    puts   "**** This will take a while...                  ****"
    print  "****************************************************"
    Recommendable.redis.flushall ## Reset the recommendable engine's state DB
    userShareCount.times {|i| ## Initialize the redis DB with user's likes
      me = User.find(i+1);
      shares[i]['contentlist'].split(' ').each {|cid|
        content = Content.find(cid) # content{id, contentlist}
        me.like(content)
      }
      kills[i]['contentlist'].split(' ').each {|cid|
        content = Content.find(cid) # content{id, contentlist}
        me.dislike(content)
      }
      print "\n#{me.id}  shares #{userShareCount}  kills #{userKillCount}"
    }
  end # def self.resetUserActions

  # Dump grid of likes between each uses
  def self.dumpLikeGrid
    # Consider content id's that are shared/killed by at least one user
    sharedActions = []
    shares.each {|s| s['contentlist'].split(' ').map {|cid| sharedActions[cid.to_i] = cid.to_i }}
    kills.each  {|s| s['contentlist'].split(' ').map {|cid| sharedActions[cid.to_i] = cid.to_i }}
    sharedActions = sharedActions.select{|e| e}
    print "\n#{sharedActions.size} contents that have been shared/killed by at least 2 users."
    # Cache the content objects
    contentFindTable = []
    sharedActions.map{|n| contentFindTable[n] = Content.find(n)}
    # Dump the table
    userShareCount.times {|uid|
      uid = uid + 1
      lme = User.find(uid);
      print "\n#{uid} [", (sharedActions.map{|n| # contains content that at least one individual likes
        if lme.likes?(contentFindTable[n])
          '*'
        elsif lme.dislikes?(contentFindTable[n])
          '-'
        else
          ' '
        end
      }.join), "]"
    }
  end

  #
  # Consider table of users
  #
  #  {"userid"=>"1"}{"userid"=>"2"}{"userid"=>"3"}{"userid"=>"4"}...
  #
  #query = "SELECT id as user_id from users"
  #accounts = $conn.exec(query)
  #accounts.each {|u| print u}

  #
  # Consider table of content.
  #
  #{"contentid"=>"1"}{"contentid"=>"2"}{"contentid"=>"3"}{"contentid"=>"4"}...
  #
  #query = "SELECT id as content_id from contents"
  #contents = $conn.exec(query)
  #contents.each {|c| print c}

  def self.probToChar p
    case p
      when 0.0
        ' '
      when (-100.0..0.0)
        ' '
      when (0.0..0.1)
        '.'
      when (0.1..0.2)
        '_'#
      when (0.2..0.3)
        '-'#▁
      when (0.3..0.4)
        '='#▂
      when (0.4..0.5)
        '*'#▃
      when (0.5..0.6)
        '%'#▄
      when (0.6..0.7)
        '$'#▅
      when (0.7..0.8)
        '#'#▆
      when (0.8..0.9)
        '&'#▇
      when (0.9..0.98)
        '#'#▉
      when (0.98..100.0)
        '@'#░
    end
  end # def self.probToChar p

  def self.dumpSimilarityGrid
    #print "[", (101.times.map{|p| probToChar(p/100.0)}.join), "]"
    # Graph of my similarity to everyone else
    userShareCount.times {|uid|
      uid = uid + 1
      print "\nSimilarity between #{uid} and: [", userShareCount.times.map{|n| n=n+1; probToChar Recommendable::Helpers::Calculations.similarity_between(uid, n) * 20.0}.join, "]"
      #print "\n", $userShareCount.times.map{|n| n=n+1; Recommendable::Helpers::Calculations.similarity_between(uid, n)}.join(' ')
    }
  end

  def self.play
    #
    # Actors
    #
    me  = User.find(1); # me{id, email, name}
    you = User.find(2); # me{id, email, name}
    meId = me.id
    youId = you.id

    print "\n**** Updating Stats... ****"
    Stopwatch.start
    Recommendable::Helpers::Calculations.update_similarities_for(meId)
    #Recommendable::Helpers::Calculations.update_recommendations_for(meId)
    Stopwatch.stop

    Stopwatch.start
    Recommendable::Helpers::Calculations.update_similarities_for(youId)
    #Recommendable::Helpers::Calculations.update_recommendations_for(youId)
    Stopwatch.stop

    #
    # SHOW ALL THE STATS
    #
    #
    # Dump table of users like count
    #
    #Stopwatch.start
    #print "\n** Likes in common with graph**"
    #$userShareCount.times {|i|
    #  print "\n"
    #  me = User.find(i+1);
    #  $userShareCount.times {|j|
    #    print " ", me.likes_in_common_with(User.find(j+1)).size;
    #  }
    #}
    #Stopwatch.stop

    print "\n\nme likes       : ",  me.liked_content_ids
    print "\nyou likes        : ", you.liked_content_ids # you.liked_content.map(&:id).join(' ')

    print "\n\nme likes_in_common_with you:", me.likes_in_common_with(you).map(&:id).join(' ')
    print "\nyou likes_in_common_with me:", you.likes_in_common_with(me).map(&:id).join(' ')

    print "\n\nc1 liked by : ", Content.find(52).liked_by.map {|x| x.id}
    print "\nc2 liked by : ", Content.find(537).liked_by.map {|x| x.id}


    print "\n\nyou similar_raters: ",  you.similar_raters.map(&:id).join(' ')
    print "\nme  similar_raters: ", me.similar_raters.map(&:id).join(' ')

    print "\npredict_for you me: ", Recommendable::Helpers::Calculations.predict_for(you.id, Content, me.id)
  end

end # module RecommendableFun


Stopwatch.start; RecommendableFun.resetUserActions; Stopwatch.stop
Stopwatch.start; RecommendableFun.dumpLikeGrid; Stopwatch.stop
Stopwatch.start; RecommendableFun.dumpSimilarityGrid; Stopwatch.stop
Stopwatch.start; RecommendableFun.play; Stopwatch.stop
#MyLib.dumpRedis
