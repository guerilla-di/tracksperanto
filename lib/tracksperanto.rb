module Tracksperanto
  VERSION = '1.0.4'
  
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
  
  module BlockInit
    def initialize
      yield(self) if block_given?
    end
  end
  
  # Internal representation of a tracker
  class Tracker
    include Casts
    include BlockInit

    # Contains the array of all Keyframe objects for this tracker
    attr_accessor :name
    
    # Contains the array of all Keyframe objects for this tracker
    attr_accessor :keyframes
    
    cast_to_string :name
    
    def initialize
      @name, @keyframes = 'Tracker', []
      super if block_given?
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
  end
end

# Load importers
Dir.glob(File.dirname(__FILE__) + '/import/*.rb').each do | i |
  require i
end

# Load exporters
Dir.glob(File.dirname(__FILE__) + '/export/*.rb').each do | i |
  require i
end

# Load middleware
Dir.glob(File.dirname(__FILE__) + '/middleware/*.rb').each do | i |
  require i
end

# Load pipelines
Dir.glob(File.dirname(__FILE__) + '/pipeline/*.rb').each do | i |
  require i
end