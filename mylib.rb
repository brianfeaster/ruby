require 'redis'

module MyLib
  def self.dumpRedis *args
    pattern = args[0]
    pattern ||= '*'
    r = Redis.new host:'redist1micro213mb.kvvtix.0001.usw2.cache.amazonaws.com'
    print "\n\n--Redis dump----\n"
    r.keys(pattern).each do |x|
      print r.type(x), " ", x, " = "
      case r.type(x)
        when 'string'
          val = r.get(x);
        when 'list'
          val = r.lrange(x, 0, -1)
        when 'hash'
          val = r.hkeys(x)
        when 'set'
          val = r.smembers(x)
        when 'zset'
          val = r.zrange(x, 0, -1)
        else
          val = "???"
      end # case r.type
      print val, "\n"
    end # r.keys
    STDOUT.flush
  end # def self.dumpRedis
end # module MyLib

module Stopwatch
  def self.start
    @@start = Time.now
  end
  def self.stop
    print  "\n", Time.now - @@start, " seconds."
  end
end
 
