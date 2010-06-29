module Wheaties
  module Concerns
    module Messaging
      STYLES = [
        Wheaties::Concerns::Formatting::BOLD,
        Wheaties::Concerns::Formatting::ITALIC,
        Wheaties::Concerns::Formatting::UNDERLINE
      ]
      PLAIN = Wheaties::Concerns::Formatting::PLAIN
      COLOR = Wheaties::Concerns::Formatting::COLOR
      
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
          when NilClass, FalseClass
            return
          when String
            lines = message.split(/[\r\n]/)
          when Array
            lines = message.flatten.map do |line|
              line.to_s.split(/[\r\n]/)
            end.flatten
          else
            lines = [message.to_s]
          end
          
          # Split long lines, respecting word wrapping and text formatting.
          max_length = max_length(command, recipients)
          styles, color = [], "" # Currently "active" text formatting.
          
          lines = lines.map do |line|
            lines = [] # We'll be splitting the input into multiple lines.
            chars = line.split("")
            buffer = "" << styles.join("") << color
            index = 0
            last_space = nil
            
            until (char = chars[index]).nil? do
              last_space = buffer.length if char == " "
              
              if STYLES.include?(char)
                styles.include?(char) ? styles.delete(char) : styles << char
              elsif char == PLAIN
                styles -= STYLES
              elsif char == COLOR
                if color.empty?
                  color = $~[0] if line[index..-1] =~ /^#{COLOR}(\d{1,2}),?(\d{1,2})?/
                else
                  color = ""
                end
              end
              
              # When we reach the maximum line length, begin a new line.
              if buffer.length >= max_length
                # If we're in the middle of a word, end the line back at the
                # last space, if there is one available.
                unless char == " " || last_space.nil?
                  temp_buffer = buffer.slice!(last_space..-1).strip
                end
                
                # Add this line, then clear the buffer and related data.
                lines << buffer
                last_space, buffer = nil, ""
                buffer << styles.join("") << color
                
                # If we were in the middle of a word, add that word to the
                # buffer in preparation for beginning the next line.
                if temp_buffer
                  buffer << temp_buffer
                  temp_buffer = nil
                end
              else
                # If we're not at the end of a line, just add this character
                # to the buffer and keep going.
                buffer << char
              end
              
              index += 1
            end
            
            lines << buffer # Add any remaining buffer as the last line.
            
            lines
          end.flatten
          
          lines.each do |line|
            broadcast(command, recipients.join(" "), :text => line)
          end
          
          return nil
        end
        
        def max_length(command, *args)
          request = Request.new(command, *args)
          510 - request.to_s.length
        end
    end
  end
end
