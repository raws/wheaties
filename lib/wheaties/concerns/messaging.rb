module Wheaties
  module Concerns
    module Messaging
      def privmsg(message, *recipients)
        ircify(message) do |message|
          broadcast(:privmsg, recipients.join(" "), :text => message)
        end
      end
      
      def notice(message, *recipients)
        ircify(message) do |message|
          broadcast(:notice, recipients.join(" "), :text => message)
        end
      end
      
      def action(message, recipient)
        broadcast_ctcp(recipient, :action, message)
      end
      
      protected
        def broadcast(command, *args)
          Connection.broadcast(command, *args)
        end
        
        def broadcast_ctcp(recipient, command, *args)
          broadcast(:privmsg, recipient, :text => "\001#{command.to_s.upcase} #{args.join(" ")}\001")
        end
        
        def ircify(message, &block)
          case message
          when String
            message = message.split(/[\r\n]/)
          when Array
            message = message.map do |line|
              line.to_s.split(/[\r\n]/)
            end.flatten
          else
            return
          end
          
          message.each do |line|
            yield line.to_s
          end
          
          return nil
        end
    end
  end
end
