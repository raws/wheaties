module Wheaties
  class Response
    attr_reader :line, :sender, :command, :args, :text
    alias_method :to_s, :line
    
    def initialize(line)
      @line = line
      parse
    end
    
    def method_name
      "on_#{command.downcase}"
    end
    
    def wheaties_method_name
      "wheaties_#{method_name}"
    end
    
    protected
      def parse
        source = line.dup
        @sender = extract!(source, /^ *:([^ ]+)/)
        @command = extract!(source, /^ *([^ ]+)/, "").upcase
        @text = extract!(source, / :(.*)$/)
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
