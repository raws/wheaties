module Wheaties
  class Handler
    include Commands::Channel
    include Commands::Ping
    include Commands::Welcome
    
    attr_reader :connection, :response
    
    def initialize(response)
      @connection = Connection.instance
      @response = response
    end
    
    def handle
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
