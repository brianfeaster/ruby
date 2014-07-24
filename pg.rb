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


$howMany = C100 
# $conn = PG.connect(dbname: 'freelogue')    # Create DB connection
# $conn = PG.connect(dbname:'ebdb', user:'ebroot', host:'aa1d5p2qk332h28.c2hupyavk0ik.us-west-2.rds.amazonaws.com', password:'freelogue2014')    # Create DB connection
$conn = PG.connect(dbname: 'postgres')    # Create DB connection


#
# Reset tables
#
def resetUsers
  $conn.exec("drop table accounts");
  $conn.exec("CREATE TABLE accounts (id SERIAL, email TEXT PRIMARY KEY, name TEXT)");
end

def resetContent
  $conn.exec("drop table contents");
  $conn.exec("CREATE TABLE contents (id SERIAL PRIMARY KEY, content TEXT)");
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
    query = "INSERT INTO accounts (email, name) VALUES('" + email + "', '" + fullName + "')"
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
# Debug dump the account and content tables
#
def dumpDataTables
  print " ------ users" + Array.new(34).join('-') + " " + Array.new(21).join('-')
  $conn.exec("SELECT * FROM users order by id") do |result|
     result.each do |row|
        print "\n %6d %-33s " % row.values_at('id', 'email')
     end
  end
  print "\n ------ contents" + Array.new(50).join('-')
  $conn.exec("SELECT * FROM contents order by id") do |result|
     result.each do |row|
        print "\n %6d %s" % row.values_at('id', 'text')
     end
  end
  print "\n ------ user_responses SHARE" + Array.new(50).join('-')
  $conn.exec("select user_id, string_agg(concat(content_id), ',') from user_responses where response = TRUE group by user_id order by user_id") do |result|
     result.each do |row|
        print "\n %6d %s" % row.values_at('user_id', 'string_agg')
     end
  end
  print "\n ------ user_responses KILL" + Array.new(50).join('-')
  $conn.exec("select user_id, string_agg(concat(content_id), ',') from user_responses where response = FALSE group by user_id order by user_id") do |result|
     result.each do |row|
        print "\n %6d %s" % row.values_at('user_id', 'string_agg')
     end
  end
  print "\n ------ user_responses IGNORE" + Array.new(50).join('-')
  $conn.exec("select user_id, string_agg(concat(content_id), ',') from user_responses where response ISNULL group by user_id order by user_id") do |result|
     result.each do |row|
        print "\n %6d %s" % row.values_at('user_id', 'string_agg')
     end
  end
end



#
# Generate random content.  Returns ID
#
def generateAndInsertNewContent ()
  ## Generate a random string between 8 and 50 characters long
  content = "";
  (8 + rand(42)).times{content << (97 + rand(26)).chr}

  ## Insert a new row into contents table
  query = "INSERT INTO contents (content) VALUES('#{content}') returning id"
  ret = $conn.exec(query)

  ## Consider and return the new row id
  ret[0]['id']
end


#
# Spread new content to all accounts
#
def _spreadNewContentGloballyInit
  query = "PREPARE seen  (bigint, bigint) AS INSERT INTO userseen VALUES($1, $2)"
  $conn.exec(query)

  query = "PREPARE share (bigint, bigint) AS INSERT INTO usershare VALUES($1, $2)"
  $conn.exec(query)

  query = "PREPARE kill  (bigint, bigint) AS INSERT INTO userkill VALUES($1, $2)"
  $conn.exec(query)
end

$users2likes = Array.new(100)
100.times {|y| $users2likes[y] = Array.new(100,0)}

def spreadNewContentGlobally label
  timeStart = Time.now
  ## Consider new content.  Consider the "id"
  idNewContent = generateAndInsertNewContent 

  ## Get ids of all users
  query = "SELECT id FROM accounts"
  idsAccounts = $conn.exec(query)

  ## Assign user the new conent
  query = ""
  idsAccounts.each {|idAccount|
    idAccount = idAccount['id'] ## Reconsider k account id from hash {"id"=>"42"}
    query += ";INSERT INTO userseen VALUES(#{idAccount}, #{idNewContent})"
    $users2likes[idAccount.to_i] ||= Array.new(100,0)
    # Users 1 and 3 vote the same
    if idAccount == "3"
      case $users2likes[1][idNewContent.to_i]
        when 1
          query += ";EXECUTE share (#{idAccount}, #{idNewContent})"
          $users2likes[idAccount.to_i][idNewContent.to_i] = 1
        when -1
          query += ";EXECUTE kill (#{idAccount}, #{idNewContent})"
          $users2likes[idAccount.to_i][idNewContent.to_i] = -1
      end
    elsif idAccount == "5"
      query += ";EXECUTE share (#{idAccount}, #{idNewContent})"
      $users2likes[idAccount.to_i][idNewContent.to_i] = 1
    elsif idAccount == "6"
      query += ";EXECUTE kill (#{idAccount}, #{idNewContent})"
      $users2likes[idAccount.to_i][idNewContent.to_i] = -1
    elsif idAccount == "7"
    else
      case rand 100
        when 0..10
          #query += ";INSERT INTO usershare VALUES(#{idAccount}, #{idNewContent})"
          query += ";EXECUTE share (#{idAccount}, #{idNewContent})"
          $users2likes[idAccount.to_i][idNewContent.to_i] = 1
        when 20..30
          #query += ";INSERT INTO userkill VALUES(#{idAccount}, #{idNewContent})"
          query += ";EXECUTE kill (#{idAccount}, #{idNewContent})"
          $users2likes[idAccount.to_i][idNewContent.to_i] = -1
        else
      end
    end
  }
  $conn.send_query(query)
  print label, " ", Time.now - timeStart, " seconds.\n"
  STDOUT.flush
end


#
# Force share to all
#
def shareAllRandomly (id)
end



def dumpLikeGraph
  puts "** Like/Dislike Graph ****"
  $users2likes.each {|row| row.each{|x| print "- *"[x+1]} ; puts }
end


#
# Main
#
timeStart = Time.now
#resetTables
#generateRandomUsers $howMany
#_spreadNewContentGloballyInit
#$howMany.times {|x| spreadNewContentGlobally "#{x}/#{$howMany}"}
#dumpLikeGraph
dumpDataTables
$conn.close
print  "\n\n", Time.now - timeStart, " seconds."
