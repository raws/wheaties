module Wheaties
  class Hostmask
    include Comparable
    
    attr_reader :nick, :user, :host
    
    def initialize(hostmask)
      if hostmask =~ /^ *([^ ]+)!([^ ]+)@([^ ]+)/
        @nick, @user, @host = *$~[1..3]
      else
        raise ErroneousHostmask, hostmask
      end
    end
    
    def to_s
      "#{nick}!#{user}@#{host}"
    end
    
    def <=>(other)
      self.to_s <=> other.to_s
    end
  end
end

class String
  def to_hostmask
    Wheaties::Hostmask.new(self.dup)
  end
end
