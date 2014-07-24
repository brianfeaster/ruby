#!/Users/brian/.rvm/rubies/ruby-2.1.2/bin/ruby


module Thing
  # Instance variable
  attr_accessor :x
  @x = 3
  # Class variable
  @@x = 4
  def self.fun
    puts "::module Thing self.fun() x='#{x}'"
    puts " -module Thing self.fun()"
    end
  def fun
    puts "::module Thing  fun() x='#{x}'"
    puts " -module Thing  fun()"
    end
  print "Inside module 'Thing' definition self = ", self, "\n"
end

puts "Mod.class = #{Thing.class}"
puts "Mod.instance_variables = #{Thing.instance_variables}"
puts "Mod.class_variables = #{Thing.class_variables}"
puts "Mod.constants = #{Thing.constants}"
puts "Mod.instance_methods = #{Thing.instance_methods}"

puts "\ninclude Thing:"; include Thing
puts "-- Thing.fun ----";
  Thing.fun
puts "-- Thing::fun ----";
  Thing::fun
puts "-- fun ----";
  fun
puts "-- Thing.x ----";
  puts "Thing.x = '#{Thing.x}'"
puts "-------------"

class Var
  @@val = 9;
  def val= newVal
    @@val = newVal
  end
  def Var.val= newVal
    @@val = newVal
  end
  def val
    @@val
  end
end

Var.val=50
print "\nCreate Var object v = ", v = Var.new, "\n"

print "\nv.val == ", v.val, "\n"
v.val = 20
print "\nv.val = 20  v.val == ", v.val, "\n"


class Fun
 @@x = 9
 @x = 10
 class << self
   attr_accessor :x
 end
end

f = Fun.new
Fun.x = 8

puts "Fun.new: #{Fun.new}"
puts "Fun.x: '#{Fun.x}'"
puts "Fun.instance_variables: '#{Fun.instance_variables}'"
puts "Fun.class_variables: '#{Fun.class_variables}'"

puts "f.instance_variables: '#{Fun.instance_variables}'"
puts "f.class_variables: '#{Fun.class_variables}'"
