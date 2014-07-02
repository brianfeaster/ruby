require 'pg'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  :database => 'freelogue',
)

class User < ActiveRecord::Base
end

#p = User.create(
#  id:    69,
#  email: "brianf@gmail",
#  name:  "brian")

p = User.new
p.id = 70;
p.name = "brianf"
p.email = "brian@gmail.com"
p.save
