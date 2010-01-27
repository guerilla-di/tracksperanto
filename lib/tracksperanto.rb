require 'stringio'
require 'delegate'
require 'tempfile'

module Tracksperanto
  PATH = File.expand_path(File.dirname(__FILE__))
  VERSION = '1.7.0'
  
  module Import; end
  module Export; end
  module Middleware; end
  module Pipeline; end
  
  class << self
    # Returns the array of all exporter classes defined
    attr_accessor :exporters
    
    # Returns the array of all importer classes defined
    attr_accessor :importers
    
    # Returns the array of all available middlewares
    attr_accessor :middlewares
    
    # Returns the names of all the importers
    def importer_names
      importers.map{|e| e.const_name }
    end
    
    # Returns the names of all the exporters
    def exporter_names
      exporters.map{|e| e.const_name }
    end
    
    # Returns the names of all the middlewares
    def middleware_names
      middlewares.map{|e| e.const_name }
    end
  end
  
  self.exporters, self.importers, self.middlewares = [], [], []
  
  # Case-insensitive search for an export module by name
  def self.get_exporter(name)
    norm = exporters.inject({}) do | table, x |
      normalized_name = x.to_s.split("::")[-1].downcase
      table.merge(normalized_name => x) 
    end
    
    norm[name] || raise( NameError, "Unknown exporter #{name}")
  end
  
  # Case-insensitive search for an export module by name
  def self.get_importer(name)
    norm = importers.inject({}) do | table, x |
      normalized_name = x.to_s.split("::")[-1].downcase
      table.merge(normalized_name => x) 
    end
    norm[name] || raise(NameError, "Unknown importer #{name}")
  end
end

%w(
  const_name
  casts
  block_init
  safety
  zip_tuples
  keyframe
  tracker
  format_detector
  ext_io
  simple_export
  uv_coordinates
).each do | submodule |
  require File.join(Tracksperanto::PATH, "tracksperanto", submodule)
end

# Load importers
Dir.glob(File.dirname(__FILE__) + '/import/*.rb').sort.each do | i |
  require i
end

# Load exporters
Dir.glob(File.dirname(__FILE__) + '/export/*.rb').sort.each do | i |
  require i
end

# Load middleware
Dir.glob(File.dirname(__FILE__) + '/middleware/*.rb').sort.each do | i |
  require i
end

# Load pipelines
Dir.glob(File.dirname(__FILE__) + '/pipeline/*.rb').sort.each do | i |
  require i
end