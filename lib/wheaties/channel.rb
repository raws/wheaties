module Wheaties
  class Channel
    include Comparable
    
    attr_reader :name, :users
    
    def initialize(name)
      @name = name
      @users = Set.new
    end
    
    def <<(other)
      if other.is_a?(User)
        @users << other
      elsif other.is_a?(Array)
        @users += other
      end
    end
    
    def delete(user)
      @users.delete(user)
    end
    
    def <=>(other)
      self.name <=> other.name
    end
    
    def to_s
      name
    end
    
    class << self
      include Wheaties::Concerns::Normalization
      
      def all
        Connection.instance.channels
      end
      
      def find(name)
        name = normalize(name)
        all.find do |channel|
          channel.name == name
        end
      end
      
      def create(name)
        new(normalize(name)).tap do |channel|
          Connection.instance.channels << channel
        end
      end
      
      def find_or_create(name)
        find(name) || create(name)
      end
      
      def delete(channel)
        Channel.all.delete(channel)
      end
    end
  end
end
