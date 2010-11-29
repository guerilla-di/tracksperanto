class Tracksperanto::Accumulator < DelegateClass(IO)
  
  attr_reader :numt
  def initialize
    __setobj__(Tracksperanto::BufferIO.new)
    @numt = 0
  end
  
  def call(with_arrived_tracker)
    
    @numt += 1
    
    d = Marshal.dump(with_arrived_tracker)
    bytelen = d.size
    write(bytelen)
    write("\t")
    write(d)
    write("\n")
  end
  
  def each_object_with_index
    rewind
    @numt.times { |i| yield(recover_tracker, i - 1) }
  end
  
  private
  
  def recover_tracker
    # Read everything upto the tab
    demarshal_bytes = gets("\t").strip.to_i
    Marshal.load(read(demarshal_bytes))
  end
end