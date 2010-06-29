$KCODE = "UTF8"

require "pathname"
require "logger"
require "yaml"

module Wheaties
  class << self
    attr_accessor :lib, :root, :config, :handlers
    
    def start
      load_root
      load_defaults
      load_application
    end
    
    def load_root
      if root = ENV["WHEATIES_ROOT"]
        Wheaties.root = Pathname.new(File.expand_path(root))
      else
        dir = Pathname.new(Dir.pwd)
        dir = dir.parent while dir != dir.parent && dir.basename.to_s !~ /\.wheaties$/
        raise LoadError, "please specify WHEATIES_ROOT" if dir == dir.parent
        Wheaties.root = dir
      end
    end
    
    def load_defaults
      config_path = Wheaties.root.join("config/irc.yml")
      Wheaties.config = YAML.load_file(config_path) || {}
      
      log_path = Wheaties.root.join("log/wheaties.log")
      Wheaties.logger = Logger.new(log_path)
      Wheaties.logger.datetime_format = "%Y-%m-%d %H:%M:%S"
      Wheaties.logger.level = Logger.const_get((Wheaties.config["log"] || "info").upcase)
    end
    
    def load_application
      Wheaties.handlers = []
      
      $:.unshift Wheaties.root.join("lib")
      load Wheaties.root.join("init.rb")
    end
    
    def register(handler)
      Wheaties.handlers << handler
    end
    
    def unregister(handler)
      Wheaties.handlers.delete(handler)
    end
  end
  
  self.lib = Pathname.new(File.dirname(__FILE__) + "/..")
end

$:.unshift Wheaties.lib

begin
  require "wheaties"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end
