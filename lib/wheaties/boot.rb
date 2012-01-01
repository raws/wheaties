require "pathname"
require "logger"
require "yaml"

module Wheaties
  class << self
    attr_accessor :lib, :root, :config, :handlers
    
    def start
      raise LoadError, "please specify WHEATIES_ROOT" unless Wheaties.root
      load_defaults
      load_application
    end
    
    def stop
      if connection = Connection.instance
        connection.broadcast("QUIT", :text => config["quit"] || "")
        EventMachine.add_timer(5) { EventMachine.stop_event_loop }
      else
        EventMachine.stop_event_loop
        Wheaties.logger.info "Wheaties stopped"
      end
    end
    
    def load_root
      if root = ENV["WHEATIES_ROOT"]
        Wheaties.root = Pathname.new(File.expand_path(root))
      else
        Wheaties.root = find_application_root_from(Dir.pwd)
      end
    end
    
    def load_defaults
      log_path = Wheaties.root.join("log", "wheaties.log")
      Wheaties.logger = Logger.new(log_path)
      Wheaties.logger.datetime_format = "%Y-%m-%d %H:%M:%S"
      
      config_path = Wheaties.root.join("config", "irc.yml")
      Wheaties.config = YAML.load_file(config_path) || {}
    end
    
    def load_application
      Wheaties.handlers = []
      $:.unshift Wheaties.root.join("lib")
      load Wheaties.root.join("init.rb")
    end
    
    def find_application_root_from(working_directory)
      dir = Pathname.new(working_directory)
      dir = dir.parent while dir != dir.parent && dir.basename.to_s !~ /\.wheaties$/i
      dir == dir.parent ? nil : dir
    end
    
    def register(handler)
      Wheaties.handlers << handler
    end
    
    def unregister(handler)
      Wheaties.handlers.delete(handler)
    end
  end
end

Wheaties.lib = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), "..")))
Wheaties.load_root
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
