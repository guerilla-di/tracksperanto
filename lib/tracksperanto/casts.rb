# Helps to define things that will forcibly become floats, integers or strings
module Tracksperanto::Casts
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
  
  def cast_to_bool(*attributes)
    attributes.each do | an_attr |
      define_method(an_attr) { !!instance_variable_get("@#{an_attr}") }
      define_method("#{an_attr}=") { |to| instance_variable_set("@#{an_attr}", !!to) }
    end
  end

end
