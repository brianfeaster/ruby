class ExampleClass
  @variable = "foo"
  @@variable = "bar"
  
  def initialize
    @variable = "baz"
  end
  
  def self.test
    print @variable
  end
  
  def test
    self.class.test
    print @@variable
    print @variable
  end
end

class ExampleSubclass < ExampleClass
  @variable = "1"
  @@variable = "2"
  
  def initialize
    @variable = "3"
  end
end

first_example = ExampleClass.new
first_example.test
print "---"
second_example = ExampleSubclass.new
second_example.test
puts "\n---------------------"



module Thing
 def fun
  'x'
 end
end

puts Thing.new.fun
