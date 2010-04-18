module Wheaties
  module Concerns
    module Messaging
      def privmsg(message, *recipients)
        broadcast(:privmsg, recipients.join(" "), :text => message)
      end
      
      def notice(message, *recipients)
        broadcast(:notice, recipients.join(" "), :text => message)
      end
      
      def action(message, recipient)
        broadcast_ctcp(recipient, :action, message)
      end
      
      protected
        def broadcast_ctcp(recipient, command, *args)
          broadcast(:privmsg, recipient, :text => "\001#{command.to_s.upcase} #{args.join(" ")}\001")
        end
    end
  end
end
