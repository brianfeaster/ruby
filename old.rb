#!/Users/brian/.rvm/rubies/ruby-2.1.2/bin/ruby

#
# Factorial -- Uses a local function and demonstrates three ways to invoke a passed block
#
def fact (x, &block)
  def _fact x
    if x < 2
      1
    else
      x * (_fact (x - 1))
    end
  end
  yield
  Proc.new.call
  block.call
  _fact x
end

for a in 1..2
  print a, ":", (fact (10) do print "[yield] " end), "\n"
end

# Chained functional object processing
puts [].push("there").push("hi").sort.first

def inspectMe (h) puts h.inspect end
inspectMe [1,2,3]

# Recursive data structure.  Ruby is sane about printing recursive structures.
data = ({'name'=>"brian", 'rest'=>0})
data['rest'] = data;
inspectMe data['rest']['rest']

#
# Demonstrate throwing and catching exceptions
#
begin
  lamb = lambda { raise }
  lamb.call
 rescue
  STDERR.puts "exception caught!"
end

#
# Is this scheme?
#
lambda {|x| puts "\n\\#{x}" }.call 5
lambda { puts "the end." }.call
