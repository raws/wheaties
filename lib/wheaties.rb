require "set"

require "eventmachine"

require "wheaties/responses/channel"
require "wheaties/responses/ping"
require "wheaties/responses/welcome"

require "wheaties/normalize"
require "wheaties/channel"
require "wheaties/connection"
require "wheaties/errors"
require "wheaties/handler"
require "wheaties/hostmask"
require "wheaties/logging"
require "wheaties/request"
require "wheaties/response"
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
