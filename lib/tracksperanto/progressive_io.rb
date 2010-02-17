# Used for IO objects that need to report the current offset at each operation that changes the said offset
# (useful for building progress bars that report on a file read operation)
class Tracksperanto::ProgressiveIO < DelegateClass(IO)
  
  # Should contain a block that accepts the current offset in bytes and the total size
  attr_accessor :progress_block
  
  # Get or set the total size of the contained IO. If the passed IO is a File object 
  # the size will be preset automatically
  attr_accessor :total_size
  
  def initialize(with_file)
    __setobj__(with_file)
    @total_size = with_file.stat.size if with_file.respond_to?(:stat)
  end
  
  def each(sep_string = $/, &blk)
    # Report offset at each call of the iterator
    result = super(sep_string) do | line |
      yield(line)
      notify_read
    end
  end
  alias_method :each_line, :each
  
  def each_byte(&blk)
    # Report offset at each call of the iterator
    super { |b| yield(b); notify_read }
  end
  
  def getc
    returning(super) { notify_read }
  end
  
  def gets
    returning(super) { notify_read }
  end
  
  def read(*a)
    returning(super) { notify_read }
  end
  
  def readbytes(*a)
    returning(super) { notify_read }
  end
  
  def readchar
    returning(super) { notify_read }
  end
  
  def readline(*a)
    returning(super) { notify_read }
  end
  
  def readlines(*a)
    returning(super) { notify_read }
  end
  
  def seek(*a)
    returning(super) { notify_read }
  end
  
  def ungetc(*a)
    returning(super) { notify_read }
  end 
  
  def pos=(p)
    returning(super) { notify_read }
  end
  
  private
    def returning(r)
      yield; r
    end
    
    def notify_read
      @progress_block.call(pos, @total_size) if @progress_block
    end
end