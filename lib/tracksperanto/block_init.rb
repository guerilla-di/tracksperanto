# Implements the conventional constructor with "hash of attributes" and block support
module Tracksperanto::BlockInit
  def initialize(attributes = {})
    attributes.map { |(k, v)| public_send("#{k}=", v) }
    yield(self) if block_given?
  end
end
