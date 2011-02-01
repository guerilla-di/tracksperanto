# An accumulator buffer for Ruby objects. Use it to sequentially store a shitload
# of objects on disk and then retreive them one by one. Make sure to call #close! when done with it to
# discard the stored blob. This object is intended to be used as a Tracksperanto::Import::Base#receiver
class Tracksperanto::Accumulator < DelegateClass(IO)
  
  # Stores the number of objects stored so far
  attr_reader :num_objects
  
  def initialize
    __setobj__(Tracksperanto::BufferIO.new)
    @num_objects = 0
  end
  
  # Store an object
  def push(object_to_store)
    
    @num_objects += 1
    
    d = Marshal.dump(object_to_store)
    bytelen = d.size
    write(bytelen)
    write("\t")
    write(d)
    write("\n")
  end
  
  # Retreive each stored object in succession and unlink the buffer
  def each_object_with_index
    rewind
    @num_objects.times { |i| yield(recover_object, i - 1) }
  end
  
  private
  
  def recover_object
    # Up to the tab is the amount of bytes to read
    demarshal_bytes = gets("\t").strip.to_i
    # Then read the bytes and unmarshal it
    Marshal.load(read(demarshal_bytes))
  end
end