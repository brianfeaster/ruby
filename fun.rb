#!/Users/brian/.rvm/rubies/ruby-2.1.2/bin/ruby

module Thing
  def Thing.fun
    puts "::module Thing Thing.fun()"
    puts " -module Thing Thing.fun()"
    end
  def fun
    puts "::module Thing  fun()"
    puts " -module Thing  fun()"
    end
  print "Inside module 'Thing' definition self = ", self, "\n"
end
puts "\ninclude Thing:"; include Thing
puts "\nInvoke fun two ways:"; Thing::fun; Thing.fun; fun

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
