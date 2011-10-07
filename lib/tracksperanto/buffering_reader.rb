# Shake uses this reader to parse byte by byte without having to read byte by byte
class Tracksperanto::BufferingReader
  DEFAULT_BUFFER_SIZE = 2048
  
  def initialize(with_io, buffer_size = DEFAULT_BUFFER_SIZE)
    @io = with_io
    @bufsize = buffer_size
    @buf = StringIO.new
  end
  
  # Will transparently read one byte off the contained IO, maintaining the internal cache.
  # If the cache has been depleted it will read a big chunk from the IO and cache it and then
  # return the byte
  def read_one_byte
    cache if @buf.pos == @buf.size
    
    return nil if @buf.size.zero?
    return @buf.read(1)
  end
  
  def eof?
    @buf.eof? && @io.eof?
  end
  
  private
  
  def cache
    data = @io.read(@bufsize)
    @buf = StringIO.new(data.to_s) # Make nil become ""
  end
end