module Wheaties
  module Responses
    module Ping
      def wheaties_on_ping
        broadcast(:pong, :text => response.text)
      end
    end
  end
end
