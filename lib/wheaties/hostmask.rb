module Wheaties
  class Hostmask
    include Comparable
    
    attr_reader :nick, :user, :host
    
    def initialize(args)
      case args
      when String
        if args =~ /^ *([^ ]+)!([^ ]+)@([^ ]+)/
          @nick, @user, @host = *$~[1..3]
        else
          raise ErroneousHostmask, args
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
      self.to_s <=> other.to_s
    end
  end
end

class String
  def to_hostmask
    Wheaties::Hostmask.new(self.dup)
  end
end
