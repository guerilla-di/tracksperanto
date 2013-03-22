# -*- encoding : utf-8 -*-
%w( stringio delegate tempfile ).map(&method(:require))

require 'bundler'
Bundler.require(:default)

module Tracksperanto
  PATH = File.expand_path(File.dirname(__FILE__))
  VERSION = '3.2.2'
  
  module Import; end
  module Export; end
  module Tool; end
  module Pipeline; end
  
  class UnknownExporterError < NameError; end
  class UnknownImporterError < NameError; end
  class UnknownToolError < NameError; end
  
  class << self
    # Returns the array of all exporter classes defined
    attr_accessor :exporters
    
    # Returns the array of all importer classes defined
    attr_accessor :importers
    
    # Returns the array of all available tools
    attr_accessor :tools
    
    # Returns the names of all the importers
    def importer_names
      importers.map{|e| e.const_name }
    end
    
    # Returns the names of all the exporters
    def exporter_names
      exporters.map{|e| e.const_name }
    end
    
    # Returns the names of all the tools
    def tool_names
      tools.map{|e| e.const_name }
    end
    
    def exporters
      sort_on_human_name(@exporters)
    end
    
    def importers
      sort_on_human_name(@importers)
    end
    
    private
    
    def sort_on_human_name(array)
      array.sort!{|a, b| a.human_name <=> b.human_name }
      array
    end
  end
  
  self.exporters, self.importers, self.tools = [], [], []

  # Case-insensitive search for a tool class by name
  def self.get_tool(name)
    tools.each do | x |
      return x if x.const_name.downcase == name.downcase
    end
    
    raise UnknownToolError, "Unknown tool #{name.inspect}"
  end
    
  # Case-insensitive search for an export module by name
  def self.get_exporter(name)
    exporters.each do | x |
      return x if x.const_name.downcase == name.downcase
    end
    
    raise UnknownExporterError, "Unknown exporter #{name.inspect}"
  end
  
  # Case-insensitive search for an export module by name
  def self.get_importer(name)
    importers.each do | x |
      return x if x.const_name.downcase == name.downcase
    end
    
    raise UnknownImporterError, "Unknown importer #{name.inspect}"
  end
  
end

%w(
  returning
  const_name
  casts
  block_init
  safety
  zip_tuples
  keyframe
  tracker
  format_detector
  ext_io
  buffer_io
  simple_export
  uv_coordinates
  parameters
  yield_non_empty
  pf_coords
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

# Load tool
Dir.glob(File.dirname(__FILE__) + '/tools/*.rb').sort.each do | i |
  require i
end

# Load pipelines
Dir.glob(File.dirname(__FILE__) + '/pipeline/*.rb').sort.each do | i |
  require i
end
