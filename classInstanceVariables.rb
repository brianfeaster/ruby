class Obj
  @x = 10;
  class << self
    attr_accessor :x
  end
end

class Sub < Obj
  @x = 100
  def self.x
    @x
  end
end

puts Obj.x
puts Sub.x
