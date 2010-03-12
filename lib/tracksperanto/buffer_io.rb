require "tempfile"

# BufferIO is used for writing big segments of text. When the segment is bigger than a certain number of bytes,
# the underlying memory buffer will be swapped with a tempfile
class Tracksperanto::BufferIO < DelegateClass(IO)
  include Tracksperanto::Returning
  
  MAX_IN_MEM_BYTES = 100_000
  
  def initialize
    __setobj__(StringIO.new)
  end
  
  def write(s)
    returning(super) { replace_with_tempfile_if_needed }
  end
  
  def puts(s)
    returning(super) { replace_with_tempfile_if_needed }
  end
  
  def <<(s)
    returning(super) { replace_with_tempfile_if_needed }
  end
  
  def putc(c)
    returning(super) { replace_with_tempfile_if_needed }
  end
  
  def close!
    __getobj__.close! if @tempfile_in
    __setobj__(nil)
  end
  
  private
  
  def replace_with_tempfile_if_needed
    return if @tempfile_in
    io = __getobj__
    if io.pos > MAX_IN_MEM_BYTES
      tf = Tempfile.new("tracksperanto-xbuf")
      tf.write(io.string)
      __setobj__(tf)
      @tempfile_in = true
    end
  end
end