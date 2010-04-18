module Wheaties
  module Concerns
    module Normalization
      def normalize(name)
        name.strip.downcase
      end
    end
  end
end
