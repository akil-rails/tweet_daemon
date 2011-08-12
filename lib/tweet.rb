# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.
require 'dbi'

class Circlog
  class << self; attr_accessor :opid end
  @opid = 0

  def self.camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    else
      lower_case_and_underscored_word.first + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end

  def self.circlog_tweet_feed(current_opid)
    # connection to DB
    dbconfig = DaemonKit::Config.load('database')
    username = dbconfig[:username]
    password = dbconfig[:password]
    dbi_connection_url = 'DBI:OCI8:' + dbconfig[:database]

    dbh = DBI.connect(dbi_connection_url, username, password)
      rs = dbh.prepare("select opid, operation, b.name, a.titleid, c.title, isbn 
      From Circlog2 A, Branches B, Titles C 
      where a.branchid = b.id
      and c.id = a.titleid
      and opid >= " + current_opid.to_s + 
      " and operation = 'D' 
      order by opid desc")
      rs.execute
      
      max_title_size = 30
      feed = Array.new
      while rsRow = rs.fetch do
         title = rsRow[4][0, max_title_size].strip.gsub(/\#/, '')
         issued_at = rsRow[2][0, max_title_size].strip.gsub(/\s/, '')
         feed << camelize(title) + ' #issued at ' + '#' + camelize(issued_at)
      end

      rs.finish
    dbh.disconnect

    return feed.uniq
  end

end
