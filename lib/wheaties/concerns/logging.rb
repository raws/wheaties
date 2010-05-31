module Wheaties
  module Concerns
    module Logging
      def log(level, *args)
        Wheaties::Connection.instance.log(level, *args)
      end
    end
  end
end
