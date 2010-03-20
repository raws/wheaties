module Wheaties
  class Error < ::StandardError; end
  class LoadError < Error; end
  
  class ErroneousHostmask < Error; end
  class ErroneousUser < Error; end
end
