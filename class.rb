#!/Users/brian/.rvm/rubies/ruby-2.1.2/bin/ruby

$NL = "\n"

class Basec #################################
  @@state = "Basec class var state = Happy"
  def initialize
    puts "::Base:initialize()  @@state==#{@@state}"
  end
  def actbase
    "::Basec:actbase()  '#{@msg}'"
  end
  def self.childclassname
    @CHILDCLASSNAME
  end
end ## class Basec ##########################

class Child < Basec
  @CHILDCLASSNAME = "Child<Basec CHILDCLASSNAME"
  @@state = "Happy"
  def self.state
    @@state
    end

  def initialize
    @msg = "Child:@msg message"
    print "::Child<Base:initialize()  state==", @@state, $NL
    end
  def act
    puts "::Child<Base:act() '#{@msg}'" 
    end
  def _fact x
    if (x < 2)
      1
    else
       x * _fact(x - 1)
    end
    end
  def fact (x, &block)
    yield
    Proc.new.call
    block.call
    _fact x
    end
end #class Child<Base

print "Child.state   =          ", Child.state, $NL

print "Instantiate Child...     ", small=Child.new, $NL

print "small.actbase() =>       ", small.actbase, $NL

print "Basec.childclassname =   ", Basec.childclassname, $NL;
print "Child.childclassname =   ", Child.childclassname, $NL;
