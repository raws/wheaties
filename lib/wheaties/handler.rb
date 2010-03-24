module Wheaties
  class Handler
    include Responses::Channel
    include Responses::Ping
    include Responses::Welcome
    
    attr_reader :connection, :response
    
    def initialize(response)
      @connection = Connection.instance
      @response = response
    end
    
    def handle
      send(response.wheaties_method_name) if respond_to?(response.wheaties_method_name)
      send(response.method_name) if respond_to?(response.method_name)
    end
    
    protected
      def log(level, *args)
        connection.log(level, *args)
      end
      
      def broadcast(command, *args)
        connection.broadcast(command, *args)
      end
  end
end
