#
# The module and submodule we will mixin at the class level (extend) or instance level (include)
#
module Stuff
  def self.fun
    puts "module:Stuff.self.fun"
  end
  module More
    def fun
      puts "module:Stuff::module:More.fun"
    end
    def x
      @x
    end
  end
end

Stuff.fun

class Obj
  include Stuff::More
  def fun2
    @x = 9
    puts "Obj.fun"
  end
end


o = Obj.new
o.fun2
puts o.x


class Obj2
  extend Stuff::More
  def fun
    @x = 9
    puts "Obj2.fun"
  end
end

Obj2.fun
o = Obj2.new
o.fun
