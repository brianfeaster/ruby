module Speak ########
  def self.speak
    puts "module:Speak:self.speak WOOF";
  end
  def speak
    puts "module.Speak.speak woof";
  end
  class Speakclass
    extend Speak
    include Speak
  end
end ## module Speak ########

class Animal ########
  extend Speak # Class
  include Speak # Instance
end ## class Animal ########

Speak.speak
Speak::Speakclass.speak
Speak::Speakclass.new.speak

# Class call
Animal.speak

# Instance call
a = Animal.new
a.speak
