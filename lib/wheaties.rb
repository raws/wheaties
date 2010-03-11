require "eventmachine"

require "wheaties/commands/channel"
require "wheaties/commands/ping"
require "wheaties/commands/welcome"

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
  def self.connect(address, port = 6667, options = {})
    EventMachine.connect(address, port, Connection, options)
  end
  
  def self.connection
    Connection.instance
  end
end
