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