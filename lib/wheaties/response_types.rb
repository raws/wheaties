module Wheaties
  module ResponseTypes
    module OnPrivmsg
      include Wheaties::Concerns::Normalization
      
      def channel
        @channel ||= if normalize(args.first) == text
                       User.find(sender)
                     else
                       Channel.find_or_create(args.first)
                     end
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
    
    module OnJoin
      def channel
        @channel ||= Channel.find_or_create(args.first)
      end
    end
    
    module OnPart
      def channel
        @channel ||= Channel.find_or_create(args.first)
      end
    end
  end
end
