#!/Users/brian/.rvm/rubies/ruby-2.1.2/bin/ruby

module Thing
 def fun
   puts "::Module::fun"
   puts "  --::Module::fun"
 end
end

include Thing

fun
