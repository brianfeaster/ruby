#!/Users/brian/.rvm/rubies/ruby-2.1.2/bin/ruby
require 'pg'

#
# Constants
#
C10   = 10
C100  = C10   * C10
C1K   = C100  * C10
C10K  = C1K   * C10
C100K = C10K  * C10
C1M   = C100K * C10
C10M  = C1M   * C10
C100M = C10M  * C10


#
# Reset tables
#
def resetUsers
  $conn.exec("drop table users");
  $conn.exec("CREATE TABLE users (id SERIAL, email TEXT PRIMARY KEY, name TEXT)");
end

def resetContent
  $conn.exec("drop table content");
  $conn.exec("CREATE TABLE content (id SERIAL PRIMARY KEY, content TEXT)");
end

def resetUserSeen
  $conn.exec("drop table userseen");
  $conn.exec("CREATE TABLE userseen (userid BIGINT, contentid BIGINT)");
end

def resetUserShare
  $conn.exec("drop table usershare");
  $conn.exec("CREATE TABLE usershare (userid BIGINT, contentid BIGINT)");
end

def resetUserKill
  $conn.exec("drop table userkill");
  $conn.exec("CREATE TABLE userkill (userid BIGINT, contentid BIGINT)");
end

def resetTables
  resetUsers
  resetContent
  resetUserSeen
  resetUserShare
  resetUserKill
end


#
# Generate random users
#

#  Create a random first, last name Of the form "First", "Last" with total length not to exceed 20 (including space)
def createRandomUserName20
  len = 20
  # Random capital letter for first and last name
  nameFirst = (65 + rand(26)).chr
  nameLast = (65 + rand(26)).chr
  # Length of first and last remaining lower case letters
  remainingFirst = rand(len - 2)            # First name can be between 1 and full length minus 2 (space and at least 1 char for last name)
  remainingLast  = rand(len - 2 - remainingFirst) # Last name between 1 and full length minus 2 (space and at least 1 char for first name
  # Remaining letters
  (remainingFirst).times{nameFirst << (97 + rand(26)).chr}
  (remainingLast).times{nameLast << (97 + rand(26)).chr}
  return nameFirst, nameLast
end

#  Create a random email address Of the form "random@random.com"
def createRandomEmail
  email = ""
  (8 + rand(10)).times{email << (97 + rand(26)).chr}
  email << "@"
  (2 + rand(10)).times{email << (97 + rand(26)).chr}
  email << ".com"
  return email
end

def generateRandomUsers (count)
  for h in 1 .. count
    # Name
    nameFirst, nameLast = createRandomUserName20
    fullName = nameFirst + " " + nameLast
    # Email
    email = createRandomEmail
    #print nameFirst, Array.new(20-fullName.length+2).join(' '), nameLast, " ", email, "\n"
    query = "INSERT INTO users (email, name) VALUES('" + email + "', '" + fullName + "')"
    #puts query
    begin
      $conn.exec(query)
    rescue
      print "Failed: ", query, "\n"
      STDOUT.flush
    end
  end
end



#
# Debug dump the user and content tables
#
def dumpDataTables
  print " ------ " + Array.new(34).join('-') + " " + Array.new(21).join('-')
  $conn.exec("SELECT * FROM users") do |result|
     result.each do |row|
        print "\n %6d %-33s %-20s" % row.values_at('id', 'email', 'name')
     end
  end
  print "\n ------ " + Array.new(50).join('-')
  $conn.exec("SELECT * FROM content") do |result|
     result.each do |row|
        print "\n %6d %s" % row.values_at('id', 'description')
     end
  end
  puts
end



#
# Generate random content
#
def generateRandomContent (count)
  for h in 1 .. count
    content = "";
    (8 + rand(42)).times{content << (97 + rand(26)).chr}
    query = "INSERT INTO content (content) VALUES('" + content + "')"
    $conn.exec(query)
  end
end

#
# Force share to all
#
def forceShareToAllUsers (id)
end



#
# Main
#
$conn = PG.connect(dbname: 'freelogue')    # Create DB connection

timeStart = Time.now

#resetTables
#generateRandomUsers C10
#generateRandomContent C10
#dumpDataTables

$conn.close
print  Time.now - timeStart, " seconds."
