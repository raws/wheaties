module Wheaties
  class Error < ::StandardError; end
  
  class ErroneousHostmask < Error; end
  class ErroneousWhoResponse < Error; end
end
