# A wrapper for IO which works on the backing buffer
# and proxies all IO methods
class Tracksperanto::IOWrapper
  extend Forwardable
  attr_reader :backing_buffer
  IO_METHODS = (IO.instance_methods - Object.instance_methods - Enumerable.instance_methods).map{|e| e.to_sym }
  def_delegators :backing_buffer, *IO_METHODS
end