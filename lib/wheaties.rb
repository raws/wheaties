require "set"

require "eventmachine"

require "wheaties/concerns/formatting"
require "wheaties/concerns/logging"
require "wheaties/concerns/messaging"
require "wheaties/concerns/normalization"

require "wheaties/responses/channel"
require "wheaties/responses/ping"
require "wheaties/responses/welcome"

require "wheaties/channel"
require "wheaties/connection"
require "wheaties/errors"
require "wheaties/handler"
require "wheaties/hostmask"
require "wheaties/logging"
require "wheaties/request"
require "wheaties/response"
require "wheaties/response_types"
require "wheaties/user"

module Wheaties
  class << self
    def connect
      address = Wheaties.config["server"]
      port = (Wheaties.config["port"] || 6667).to_i
      
      EventMachine.connect(address, port, Connection)
    end
  
    def connection
      Connection.instance
    end
  end
end
