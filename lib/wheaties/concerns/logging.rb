module Wheaties
  module Concerns
    module Logging
      def log(level, *args)
        Wheaties.logger.send(level, args.join(" "))
      end
    end # Logging
  end # Concerns
end
