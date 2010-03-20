module Wheaties
  class User
    include Comparable
    
    attr_reader :hostmask, :modes
    
    def initialize(args)
      if args.is_a?(Hostmask)
        @hostmask = args
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
    
    def user
      hostmask.user
    end
    
    def host
      hostmask.host
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
      
      def find(args)
        all.find do |user|
          if args.is_a?(Hostmask)
            user.hostmask == args
          else
            args.inject(true) do |result, arg|
              result && (user.send(arg[0]) == arg[1])
            end
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
