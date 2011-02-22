# An accumulator buffer for Ruby objects. Use it to sequentially store a shitload
# of objects on disk and then retreive them one by one. Make sure to call #close! when done with it to
# discard the stored blob (will also happen after iterating through objects, even when an exception is raised).
# This object is intended to be used as a Tracksperanto::Import::Base#receiver
class Tracksperanto::Accumulator
  include Enumerable
  
  # Stores the number of objects stored so far
  attr_reader :num_objects
  alias_method :length, :num_objects
  
  def initialize
    @store = Tracksperanto::BufferIO.new
    @num_objects = 0
    super
  end
  
  # Store an object
  def push(object_to_store)
    @num_objects += 1
    d = Marshal.dump(object_to_store)
    [d.size, "\t", d, "\n"].map(&@store.method(:write))
  end
  
  # Retreive each stored object in succession and unlink the buffer
  def each
    @store.rewind
    @num_objects.times { yield(recover_object) }
  end
  
  # Might be useful - calls close! and destroyhs the store
  def clear!
    @store.close!
  end
  
  private
  
  def recover_object
    # Up to the tab is the amount of bytes to read
    demarshal_bytes = @store.gets("\t").strip.to_i
    # Then read the bytes and unmarshal it
    Marshal.load(@store.read(demarshal_bytes))
  end
end
