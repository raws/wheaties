module Wheaties
  class Connection < EventMachine::Protocols::LineAndTextProtocol
    attr_reader :options, :nick, :user, :real, :pass, :channels
    attr_accessor :connected
    
    class << self
      def instance
        @@instance
      end
    end
    
    def initialize(options)
      @@instance = self
      
      @connected = false
      @options = options
      @nick = options[:nick] || "Wheaties"
      @user = options[:user] || "wheaties"
      @real = options[:real] || "Wheaties"
      @pass = options[:pass]
      @channels = {}
      
      super
    end
    
    def post_init
      log(:info, "Connection opened")
      
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
    
    def channel(name)
      name.downcase!
      channels.fetch(name) do |name|
        channels[name] = Channel.new(name)
      end
    end
  end
end
