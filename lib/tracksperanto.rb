module Tracksperanto
  
  module Import; end
  module Export; end
  module Middleware; end
  
  class << self
    attr_accessor :exporters
    attr_accessor :importers
    attr_accessor :middlewares
  end
  self.exporters, self.importers, self.middlewares = [], [], []
  
  module Casts
    def self.included(into)
      into.extend(self)
      super
    end

    def cast_to_float(*attributes)
      attributes.each do | an_attr |
        define_method(an_attr) { instance_variable_get("@#{an_attr}").to_f }
        define_method("#{an_attr}=") { |to| instance_variable_set("@#{an_attr}", to.to_f) }
      end
    end
    
    def cast_to_int(*attributes)
      attributes.each do | an_attr |
        define_method(an_attr) { instance_variable_get("@#{an_attr}").to_i }
        define_method("#{an_attr}=") { |to| instance_variable_set("@#{an_attr}", to.to_i) }
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
    include BlockInit
    attr_accessor :name, :keyframes
    def initialize
      @name, @keyframes = 'Tracker', []
      super if block_given?
    end
  end
  
  # Internal representation of a keyframe
  class Keyframe
    include Tracksperanto::Casts
    include Tracksperanto::BlockInit
    
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