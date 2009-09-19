require 'stringio'
require 'delegate'

module Tracksperanto
  VERSION = '1.2.0'
  
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
  end
  self.exporters, self.importers, self.middlewares = [], [], []
  
  # Helps to define things that will forcibly become floats, integers or strings
  module Casts
    def self.included(into)
      into.extend(self)
      super
    end
    
    # Same as attr_accessor but will always convert to Float internally
    def cast_to_float(*attributes)
      attributes.each do | an_attr |
        define_method(an_attr) { instance_variable_get("@#{an_attr}").to_f }
        define_method("#{an_attr}=") { |to| instance_variable_set("@#{an_attr}", to.to_f) }
      end
    end
    
    # Same as attr_accessor but will always convert to Integer/Bignum internally
    def cast_to_int(*attributes)
      attributes.each do | an_attr |
        define_method(an_attr) { instance_variable_get("@#{an_attr}").to_i }
        define_method("#{an_attr}=") { |to| instance_variable_set("@#{an_attr}", to.to_i) }
      end
    end
    
    # Same as attr_accessor but will always convert to String internally
    def cast_to_string(*attributes)
      attributes.each do | an_attr |
        define_method(an_attr) { instance_variable_get("@#{an_attr}").to_s }
        define_method("#{an_attr}=") { |to| instance_variable_set("@#{an_attr}", to.to_s) }
      end
    end
  end
  
  # Implements the +safe_reader+ class method which will define (or override) readers that
  # raise if ivar is nil
  module Safety
    def self.included(into)
      into.extend(self)
      super
    end
    
    # Inject a reader that checks for nil
    def safe_reader(*attributes)
      attributes.each do | an_attr |
        alias_method "#{an_attr}_without_nil_protection", an_attr
        define_method(an_attr) do
          val = send("#{an_attr}_without_nil_protection")
          raise "Expected #{an_attr} on #{self} not to be nil" if val.nil?
          val
        end
      end
    end
  end
  
  # Implements the conventional constructor with "hash of attributes" and block support
  module BlockInit
    def initialize(object_attribute_hash = {})
      object_attribute_hash.map { |(k, v)| send("#{k}=", v) }
      yield(self) if block_given?
    end
  end
  
  # Implements the zip_curve_tuples method
  module ZipTuples
    # Zip arrays of "value at" tuples into an array of "values at" tuples. 
    # The first value of each tuple will be the frame number
    # and keyframes which are not present in all arrays will be discarded. For example:
    #
    #    zip_curve_tuples( [[0, 12], [1, 23]], [[1, 12]]) #=> [[1, 23, 12]]
    #
    def zip_curve_tuples(*curves)
      tuples = []
      curves.each do | curve |
        curve.each do | keyframe |
          frame, value = keyframe
          tuples[frame] ? tuples[frame].push(value) : (tuples[frame] = [frame, value])
        end
      end

      tuples.compact.reject{|e| e.length < (curves.length + 1) }
    end
  end
  
  # Internal representation of a tracker
  class Tracker < DelegateClass(Array)
    include Casts
    include Comparable
    
    # Contains the name of the tracker
    attr_accessor :name
    cast_to_string :name
    
    def initialize(object_attribute_hash = {})
      @name = "Tracker"
      __setobj__(Array.new)
      object_attribute_hash.map { |(k, v)| send("#{k}=", v) }
      yield(self) if block_given?
    end
    
    def keyframes=(new_kf_array)
      __setobj__(new_kf_array.dup)
    end
    
    def keyframes
      __getobj__
    end
    
    # Trackers sort by the position of the first keyframe
    def <=>(other_tracker)
      self[0].frame <=> other_tracker[0].frame
    end
    
    # Create and save a keyframe in this tracker
    def keyframe!(options)
      push(Keyframe.new(options))
    end
    
    def inspect
      "<T #{name.inspect} with #{length} keyframes>"
    end
  end
  
  # Internal representation of a keyframe
  class Keyframe
    include Casts
    include BlockInit
    
    # Absolute integer frame where this keyframe is placed, 0 based
    attr_accessor :frame
    
    # Absolute float X value of the point, zero is lower left
    attr_accessor :abs_x
    
    # Absolute float Y value of the point, zero is lower left
    attr_accessor :abs_y
    
    # Absolute float residual (0 is "spot on")
    attr_accessor :residual
    
    cast_to_float :abs_x, :abs_y, :residual
    cast_to_int :frame
    
    def inspect
      [frame, abs_x, abs_y].inspect
    end
  end
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