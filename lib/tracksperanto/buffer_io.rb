require "tempfile"

# BufferIO is used for writing big segments of text. It works like a StringIO, but when the size
# of the underlying string buffer exceeds MAX_IN_MEM_BYTES the string will be flushed to disk
# and it automagically becomes a Tempfile
class Tracksperanto::BufferIO < DelegateClass(IO)
  include Tracksperanto::Returning
  
  MAX_IN_MEM_BYTES = 5_000_000
  
  def initialize
    __setobj__(StringIO.new)
  end
  
  def write(s)
    returning(super) { replace_with_tempfile_if_needed }
  end
  alias_method :<<, :write
  
  def puts(s)
    returning(super) { replace_with_tempfile_if_needed }
  end
  
  def putc(c)
    returning(super) { replace_with_tempfile_if_needed }
  end
  
  def close!
    __getobj__.close! if @tempfile_in
    __setobj__(nil)
  end
  
  # Used by IO.reopen. When we do that we need to go to a tempfile regardless
  def to_io
    replace_with_tempfile unless @tempfile_in
    super
  end
  
  private
  
  def replace_with_tempfile
    sio = __getobj__
    tf = Tempfile.new("tracksperanto-xbuf")
    tf.write(sio.string)
    sio.string = ""
    GC.start
    __setobj__(tf)
    
    @tempfile_in = true
  end
  
  def replace_with_tempfile_if_needed
    replace_with_tempfile if !@tempfile_in && pos > MAX_IN_MEM_BYTES
  end
end