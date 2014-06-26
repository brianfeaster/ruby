#!/Users/brian/.rvm/rubies/ruby-2.1.2/bin/ruby

class Big
  @@state = "Happy"
  def initialize
    @state = @@state
    puts "#{@state} for initializing me"
    puts "#{@@state} for initializing me"
  end
  
  def _fact x
    if (x < 2)
      1
    else
       x * _fact(x - 1)
    end
  end

  def fact x
    yield
    _fact x
  end

end

small = Big.new


for a in 1..3
  print a, ":", (small.fact (10) { puts "-- fact ----"}), "\n"
end

puts [].push("there").push("hi").sort.first

def inspectMe (h) 
   puts h.inspect
end
inspectMe [1,2,3]

data = ({'name'=>"brian", 'rest'=>0})
data['rest'] = data;

inspectMe data['rest']['rest']

begin
  lamb = lambda { raise }
  lamb.call
 rescue
  STDERR.puts "exception caught!"
end

[1,'a',5.5].each {|x| print("[", " '#{x}'", "]")}
puts

lambda { puts "the end." }.call
lambda {|x| puts "#{x}the end." }.call 5
