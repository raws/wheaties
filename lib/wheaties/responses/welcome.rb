module Wheaties
  module Responses
    module Welcome
      # RPL_ENDOFMOTD
      def on_376
        log(:debug, "Connection established")
        
        performs = Wheaties.config["auto"]
        performs.each do |command|
          if command =~ /^(.*?)\s+(.*)$/
            broadcast($~[1], $~[2])
          end
        end if performs
        
        channels = Wheaties.config["channels"]
        channels.each do |channel|
          broadcast(:join, channel)
        end
      end
      
      # ERR_NOMOTD
      alias :on_422 :on_376
    end
  end
end
