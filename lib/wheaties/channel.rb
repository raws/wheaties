require "set"

module Wheaties
  class Channel
    include Comparable
    
    attr_reader :name, :users
    
    def initialize(name)
      @name = name
      @users = Set.new
    end
    
    def <<(user)
      @users << user
    end
    
    def <=>(other)
      self.name <=> other.name
    end
  end
end
