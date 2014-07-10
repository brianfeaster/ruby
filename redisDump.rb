#!/Users/brian/.rvm/rubies/ruby-2.1.2/bin/ruby

load 'mylib.rb'

if 0 != ARGV.length;
  ARGV.each {|pat| MyLib.dumpRedis pat }
else
  MyLib.dumpRedis
end
