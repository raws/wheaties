require "set"

module Wheaties
  class User
    include Comparable
    
    attr_reader :hostmask, :modes
    
    def initialize(response)
      if response.command == "352" && response.args.size >= 7
        source = response.args.dup
        nick = source[4]
        user = source[1]
        host = source[2]
        modes = source[5][/^([GH])(.*)$/, 2].split("")
        real = source[6][/^[0-9] +(.*)$/, 1]
        
        @hostmask = Hostmask.new("#{nick}!#{user}@#{host}")
        @modes = Set.new(modes)
      else
        raise ErroneousWhoResponse, response
      end
    end
    
    def nick
      hostmask.nick
    end
    
    def user
      hostmask.user
    end
    
    def host
      hostmask.host
    end
    
    def <=>(other)
      self.hostmask <=> other.hostmask
    end
  end
end  
