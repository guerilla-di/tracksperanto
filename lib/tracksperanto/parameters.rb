module Tracksperanto::Parameters
  
  def self.included(into)
    into.extend(self)
    super
  end
  
  class Parameter
    include Tracksperanto::BlockInit
    
    # The name of the paramenter and the related object attribute
    attr_accessor :name
    
    # Whether the attribute is required
    attr_accessor :required
    
    # Default value of the attribute
    attr_accessor :default
    
    # The cast for the attribute (like :int or :float)
    attr_accessor :cast
    
    # Attribute description for the UI
    attr_accessor :desc
    
    def apply_to(to_class)
      to_class.send(:attr_accessor, name)
      
      if cast
        cast_call = "cast_to_#{cast}"
        to_class.send(cast_call, name)
      end
      
      if required
        to_class.safe_reader name
      end
      
    end
  end
  
  # Defines a parameter, options conform to the Parameter class.
  def parameter(name, options = {})
    options = {:name => name}.merge(options)
    param = Parameter.new(options)
    parameters.push(param)
    param.apply_to(self)
  end
  
  def parameters
    @ui_parameters ||= []
    @ui_parameters
  end
end