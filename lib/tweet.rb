# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.

class Circlog
  class << self; attr_accessor :opid end
  @opid = 0
end
