# An accumulator buffer for Ruby objects. Use it to sequentially store a shitload
# of objects on disk and then retreive them one by one. Make sure to call #close! when done with it to
# discard the stored blob (will also happen after iterating through objects, even when an exception is raised).
# This object is intended to be used as a Tracksperanto::Import::Base#receiver
class Tracksperanto::Accumulator
  include Enumerable
  
  # Returns the number of objects stored so far
  attr_reader :size
  
  def initialize
    @store = Tracksperanto::BufferIO.new
    @size = 0
    super
  end
  
  # Store an object
  def push(object_to_store)
    @size += 1
    d = Marshal.dump(object_to_store)
    [d.size, "\t", d, "\n"].map(&@store.method(:write))
  end
  
  # Retreive each stored object in succession and unlink the buffer
  def each
    @store.rewind
    @size.times { yield(recover_object) }
  end
  
  # Calls close! on the datastore and deletes the objects in it
  def clear
    @store.close!
    @size = 0
  end
  
  private
  
  def recover_object
    # Up to the tab is the amount of bytes to read
    demarshal_bytes = @store.gets("\t").strip.to_i
    Marshal.load(@store.read(demarshal_bytes))
  end
end
