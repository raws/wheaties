module Wheaties
  class Handler
    include Wheaties::Concerns::Formatting
    include Wheaties::Concerns::Logging
    include Wheaties::Concerns::Messaging
    
    attr_reader :connection, :response
    
    def initialize(response)
      @connection = Connection.instance
      @response = response
    end
    
    def handle
      send(response.method_name) if respond_to?(response.method_name)
    end
  end # Handler
  
  class WheatiesHandler < Handler
    include Responses::Channel
    include Responses::Ping
    include Responses::Welcome
    
    alias :original_handle :handle
    
    def handle
      original_handle
      
      Wheaties.handlers.each do |klass|
        handler = klass.new(response).handle
      end
    end
  end # WheatiesHandler
end
