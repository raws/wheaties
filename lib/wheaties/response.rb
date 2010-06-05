module Wheaties
  class Response
    attr_reader :line, :sender, :command, :args, :text
    alias_method :to_s, :line
    
    def initialize(line)
      @line = line
      parse
      modulize
    end
    
    def method_name
      "on_#{command.downcase}"
    end
    
    protected
      def parse
        source = line.dup
        @sender = extract!(source, /^ *:([^ ]+)/)
        @command = extract!(source, /^ *([^ ]+)/, "").upcase
        @text = extract!(source, / :(.*)$/)
        
        if @text =~ /^\001([^\001]+)\001$/
          @command = "CTCP"
          @text = $~[1]
          
          if @text =~ /^ACTION\s+(.*)$/i
            @command = "ACTION"
            @text = $~[1]
          end
        end
        
        @args = source.strip.split(" ")
        @args.shift if @args.first == Connection.instance.nick
        
        begin
          @sender = @sender.to_hostmask if @sender
        rescue ErroneousHostmask; end
        
        if @text
          @args.push(@text)
        else
          @text = @args.last
        end
      end
      
      def modulize
        module_name = "On#{command.capitalize}"
        if ResponseTypes.const_defined?(module_name)
          self.class.class_eval { include ResponseTypes.const_get(module_name) }
        end
      end
      
      def extract!(line, regex, default = nil)
        result = nil
        line.gsub!(regex) do |match|
          result = $~[1]
          ""
        end
        result || default
      end
  end
  
  module ResponseTypes
    module OnPrivmsg
      include Wheaties::Concerns::Normalization
      
      def channel
        @channel ||= normalize(args.first) == text ? sender.nick : normalize(args.first)
      end
      
      def pm?
        channel == sender.nick
      end
    end
    
    module OnCtcp
      include OnPrivmsg
      
      def ctcp_command
        parse_ctcp
        @ctcp_command
      end
      
      def ctcp_args
        parse_ctcp
        @ctcp_args
      end
      
      private
        def parse_ctcp
          @ctcp_args = text.strip.split(" ") unless @ctcp_args
          @ctcp_command = @ctcp_args.shift unless @ctcp_command
        end
    end
    
    module OnNick
      def old_nick
        sender.nick
      end
      
      def new_nick
        args.first
      end
    end
  end
end
