module Wheaties
  class Connection < EventMachine::Protocols::LineAndTextProtocol
    attr_reader :nick, :user, :real, :pass
    attr_accessor :connected, :channels
    
    class << self
      def instance
        @@instance
      end
    end
    
    def initialize
      @@instance = self
      
      @connected = false
      @nick = Wheaties.config["nick"]
      @user = Wheaties.config["user"]
      @real = Wheaties.config["real"]
      @pass = Wheaties.config["pass"]
      @channels = Set.new
      
      super
    end
    
    def post_init
      log(:info, "Connection opened")
      
      Signal.trap("INT") do
        close_connection_after_writing
        EM.stop_event_loop
      end
      
      identify
    end
    
    def identify
      broadcast("PASS", pass) if pass
      broadcast("NICK", nick)
      broadcast("USER", user, "0", "*", :text => real)
    end
    
    def receive_line(line)
      operator = Proc.new do
        begin
          response = Response.new(line)
          log(:debug, "<--", response.to_s.inspect)
          Handler.new(response).handle
        rescue => e
          log(:error, e.message, e.backtrace)
        end
      end
      
      callback = Proc.new do |result|
        instance_eval(&result) if result.is_a?(Proc)
      end
      
      EM.defer(operator, callback)
    end
    
    def unbind
      log(:info, "Connection closed")
    end
    
    def broadcast(command, *args)
      @sender ||= EventMachine.spawn do |command, *args|
        connection = Connection.instance
        request = Request.new(command, *args)
        connection.send_data(request.to_s)
        connection.log(:debug, "-->", request.to_s.inspect) unless request.sensitive?
      end.notify(command, *args)
    end
    
    def log(level, *args)
      Wheaties.logger.send(level, args.join(" "))
    end
    
    def connected?
      @connected
    end
  end
end
