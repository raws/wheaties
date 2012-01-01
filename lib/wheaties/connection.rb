module Wheaties
  class Connection < EventMachine::Protocols::LineAndTextProtocol
    include Wheaties::Concerns::Logging
    
    attr_reader :nick, :user, :real, :channels
    
    class << self
      attr_accessor :instance
      
      def method_missing(method, *args)
        self.instance.send(method, *args)
      rescue NoMethodError => e
        raise e
      end
    end
    
    def initialize
      Connection.instance = self
      @nick = Wheaties.config["nick"]
      @user = Wheaties.config["user"]
      @real = Wheaties.config["real"]
      @channels = Set.new
      super
    end
    
    def post_init
      set_comm_inactivity_timeout((Wheaties.config["timeout"] || 300).to_i)
      
      if Wheaties.config["ssl"] === true
        start_tls
        log(:info, "SSL connection opened")
      else
        log(:info, "Connection opened")
      end
      
      identify
      add_periodic_who
    end
    
    def identify
      pass = Wheaties.config["pass"]
      broadcast("PASS", pass) if pass
      broadcast("NICK", nick)
      broadcast("USER", user, "0", "*", :text => real)
    end
    
    def add_periodic_who
      EM.add_periodic_timer(600) do
        Channel.all.each do |channel|
          broadcast(:who, channel)
        end
      end
    end
    
    def receive_line(line)
      EM.defer do
        begin
          response = Response.new(line)
          log(:debug, "Received", response.to_s.inspect)
          WheatiesHandler.new(response).handle
        rescue => e
          log(:error, e.message, e.backtrace.join("\n"))
        end
      end
    end
    
    def unbind
      log(:info, "Connection closed")
      EventMachine.stop_event_loop
      Wheaties.logger.info "Wheaties stopped"
    end
    
    def broadcast(command, *args)
      (@sender ||= EM.spawn do |command, *args|
        connection = Connection.instance
        request = Request.new(command, *args)
        connection.send_data(request.to_s)
        connection.log(:debug, "Sent", request.to_s.inspect) unless request.sensitive?
      end).notify(command, *args)
    end
  end # Connection
end
