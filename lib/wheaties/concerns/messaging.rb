module Wheaties
  module Concerns
    module Messaging
      def privmsg(message, *recipients)
        broadcast_message(:privmsg, message, recipients)
      end
      
      def notice(message, *recipients)
        broadcast_message(:notice, message, recipients)
      end
      
      def action(message, recipient)
        broadcast_ctcp(recipient, :action, message)
      end
      
      protected
        def broadcast(command, *args)
          Connection.broadcast(command, *args)
        end
        
        def broadcast_ctcp(recipient, command, *args)
          max_length = max_length(:privmsg, recipient) - (3 + command.to_s.length)
          broadcast(:privmsg, recipient, :text => "\001#{command.to_s.upcase} #{args.join(" ")[0, max_length]}\001")
        end
        
        def broadcast_message(command, message, recipients)
          case message
          when String
            lines = message.split(/[\r\n]/)
          when Array
            lines = message.map do |line|
              line.to_s.split(/[\r\n]/)
            end.flatten
          else
            return
          end
          
          lines.each do |line|
            broadcast(command, recipients.join(" "), :text => message)
          end
          
          return nil
        end
        
        def max_length(command, *args)
          request = Request.new(command, *args)
          512 - (request.to_s.length + 2)
        end
    end
  end
end
