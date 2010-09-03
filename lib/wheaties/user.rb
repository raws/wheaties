module Wheaties
  class User
    include Comparable
    include Concerns::Logging
    
    attr_reader :hostmask, :modes
    
    def initialize(args)
      if args.is_a?(Hostmask)
        @hostmask = args.dup
        @modes = Set.new
      else
        @hostmask = Hostmask.new(:nick => args[:nick],
                                 :user => args[:user],
                                 :host => args[:host])
        @modes = Set.new(args[:modes])
      end
    end
    
    def nick
      hostmask.nick
    end
    
    def nick=(nick)
      hostmask.nick = nick
    end
    
    def user
      hostmask.user
    end
    
    def host
      hostmask.host
    end
    
    def delete!
      Channel.all.each do |channel|
        channel.delete(self)
      end
    end
    
    def <=>(other)
      self.hostmask <=> other.hostmask
    end
    
    def to_s
      hostmask.to_s
    end
    
    class << self
      def all
        Channel.all.inject(Set.new) do |users, channel|
          users.merge(channel.users)
        end
      end
      
      def find(query)
        all.find do |user|
          case query
          when String then user.nick == query
          when Hash then user.nick == query[:nick]
          when Hostmask then user.hostmask == query
          end
        end
      end
      
      def create(args)
        new(args)
      end
      
      def find_or_create(args)
        find(args) || create(args)
      end
    end
  end
end  
