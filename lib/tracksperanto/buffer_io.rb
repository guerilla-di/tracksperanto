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
  
  # Sometimes you just need to upgrade to a File forcibly (for example if you want)
  # to have an object with many iterators sitting on it. We also flush here.
  def to_file
    replace_with_tempfile unless @tempfile_in
    flush
    self
  end
  
  # Tells whether this one is on disk
  def file_backed?
    @tempfile_in
  end
  
  private
  
  def replace_with_tempfile
    sio = __getobj__
    tf = Tempfile.new("tracksperanto-xbuf")
    tf.write(sio.string)
    tf.flush # Needed of we will reopen this file soon from another thread/loop
    sio.string = ""
    GC.start
    __setobj__(tf)
    
    @tempfile_in = true
  end
  
  def replace_with_tempfile_if_needed
    replace_with_tempfile if !@tempfile_in && pos > MAX_IN_MEM_BYTES
  end
end