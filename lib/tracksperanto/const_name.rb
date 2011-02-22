# Provides const_name that returns the name of the class or module (or the name of the class
# an instance belongs to)  without it's parent namespace. Useful for building module tables
module Tracksperanto::ConstName
  module C
    def const_name
      to_s.split('::').pop
    end
  end
  
  def const_name
    self.class.const_name
  end
  
  def self.included(into)
    into.extend(C)
    super
  end
end