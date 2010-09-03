module Wheaties
  module Responses
    module Channel
      def on_join
        channel = response.channel
        
        if response.sender.nick == connection.nick
          broadcast(:who, channel)
          log(:info, "Joined", channel)
        else
          user = User.find_or_create(response.sender)
          channel << user
        end
      end
      
      def on_part
        channel = response.channel
        
        if response.sender.nick == connection.nick
          Wheaties::Channel.delete(channel)
          log(:info, "Left", channel)
        else
          user = User.find_or_create(response.sender)
          channel.delete(user)
        end
      end
      
      def on_quit
        user = User.find_or_create(response.sender)
        user.delete! if user
      end
      
      def on_nick
        user = User.find(:nick => response.old_nick)
        user.nick = response.new_nick if user
      end
      
      # RPL_WHOREPLY
      def on_352
        channel = response.args.first
        nick = response.args[4]
        user = response.args[1]
        host = response.args[2]
        modes = response.args[5][/^([GH])(.*)$/, 2].split("")
        # real = response.args[6][/^[0-9] +(.*)$/, 1]
        user = User.find_or_create(:nick => nick,
                                   :user => user,
                                   :host => host,
                                   :modes => modes)
        Wheaties::Channel.find_or_create(channel).new_users << user
      end
      
      # RPL_ENDOFWHO
      def on_315
        channel = response.args.first
        Wheaties::Channel.find_or_create(channel).flush!
      end
    end
  end
end
