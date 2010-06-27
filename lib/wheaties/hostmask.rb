module Wheaties
  class Hostmask
    include Comparable
    
    attr_reader :user, :host
    attr_accessor :nick
    
    def initialize(args)
      case args
      when String
        if args =~ /^ *([^ ]+)!([^ ]+)@([^ ]+)/
          @nick, @user, @host = *$~[1..3]
        else
          @nick = args
        end
      when Hash
        @nick = args[:nick]
        @user = args[:user]
        @host = args[:host]
      else
        raise ErroneousHostmask, args
      end
    end
    
    def to_s
      "#{nick}!#{user}@#{host}"
    end
    
    def <=>(other)
      self.to_s.downcase <=> other.to_s.downcase
    end
  end
end

class String
  def to_hostmask
    Wheaties::Hostmask.new(self.dup)
  end
end
