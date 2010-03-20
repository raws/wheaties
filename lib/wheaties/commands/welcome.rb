module Wheaties
  module Commands
    module Welcome
      # RPL_ENDOFMOTD
      def on_376
        log(:debug, "Connection established")
        
        Proc.new do
          connected = true
          
          channels = Wheaties.config["channels"]
          channels.each do |channel|
            broadcast(:join, channel)
          end
        end
      end
      
      # ERR_NOMOTD
      alias_method :on_422, :on_376
    end
  end
end
