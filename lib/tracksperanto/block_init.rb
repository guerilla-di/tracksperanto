# -*- encoding : utf-8 -*-
# Implements the conventional constructor with "hash of attributes" and block support
module Tracksperanto::BlockInit
  def initialize(object_attribute_hash = {})
    object_attribute_hash.map { |(k, v)| send("#{k}=", v) }
    yield(self) if block_given?
  end
end
