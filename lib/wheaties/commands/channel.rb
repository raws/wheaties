module Wheaties
  module Commands
    module Channel
      def on_join
        channel = response.args.first
        
        if response.sender.nick == connection.nick
          broadcast(:who, channel)
          log(:info, "Joined", channel)
        end
      end
      
      # RPL_WHOREPLY
      def on_352
        channel = response.args.first
        user = User.new(response)
        connection.channel(channel) << user
      end
      
      # RPL_ENDOFWHO
      def on_315
        channel = response.args.first
        log(:debug, connection.channel(channel).inspect)
      end
    end
  end
end
