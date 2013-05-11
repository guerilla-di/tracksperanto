# -*- encoding : utf-8 -*-
# Implements the conventional constructor with "hash of attributes" and block support
module Tracksperanto::BlockInit
  def initialize(object_attribute_hash = {})
    m = method(respond_to?(:public_send) ? :public_send : :send)
    object_attribute_hash.map { |(k, v)| m.call("#{k}=", v) }
    yield(self) if block_given?
  end
end
