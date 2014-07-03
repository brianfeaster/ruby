module MyLib
  def self.dumpRedis
    puts "\n--Redis dump----"
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
    STDOUT.flush
  end # def self.dumpRedis
end # module MyLib
