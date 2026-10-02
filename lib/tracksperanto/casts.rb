# frozen_string_literal: true
# Helps to define things that will forcibly become floats, integers or strings
module Tracksperanto::Casts
  def self.included(into)
    into.extend(self)
    super
  end
  
  # The accessors are generated from strings rather than with define_method, because
  # methods defined with a block can't be called from a non-main Ractor

  # Same as attr_accessor but will always convert to Float internally
  def cast_to_float(*attributes)
    attributes.each do | an_attr |
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{an_attr}; @#{an_attr}.to_f; end
        def #{an_attr}=(to); @#{an_attr} = to.to_f; end
      RUBY
    end
  end
  
  # Same as attr_accessor but will always convert to Integer/Bignum internally
  def cast_to_int(*attributes)
    attributes.each do | an_attr |
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{an_attr}; @#{an_attr}.to_i; end
        def #{an_attr}=(to); @#{an_attr} = to.to_i; end
      RUBY
    end
  end
  
  # Same as attr_accessor but will always convert to String internally
  def cast_to_string(*attributes)
    attributes.each do | an_attr |
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{an_attr}; @#{an_attr}.to_s; end
        def #{an_attr}=(to); @#{an_attr} = to.to_s; end
      RUBY
    end
  end
  
  def cast_to_bool(*attributes)
    attributes.each do | an_attr |
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{an_attr}; !!@#{an_attr}; end
        def #{an_attr}=(to); @#{an_attr} = !!to; end
      RUBY
    end
  end

end
