module Wheaties
  module Responses
    module Welcome
      # RPL_ENDOFMOTD
      def wheaties_on_376
        log(:debug, "Connection established")
        
        channels = Wheaties.config["channels"]
        channels.each do |channel|
          broadcast(:join, channel)
        end
      end
      
      # ERR_NOMOTD
      alias_method :wheaties_on_422, :wheaties_on_376
    end
  end
end
