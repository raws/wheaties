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
      :"on_#{command.downcase}"
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
end
