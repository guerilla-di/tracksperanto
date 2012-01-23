# -*- encoding : utf-8 -*-
# Implements the +safe_reader+ class method which will define (or override) readers that
# raise if ivar is nil
module Tracksperanto::Safety
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
