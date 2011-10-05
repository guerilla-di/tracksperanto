class Tracksperanto::BufferingReader < DelegateClass(IO)
  DEFAULT_BUFFER_SIZE = 2048
  
  def initialize(with_io, buffer_size = DEFAULT_BUFFER_SIZE)
    __setobj__(with_io)
    @bufsize = DEFAULT_BUFFER_SIZE
    
    @buf = StringIO.new
    cache!(@bufsize)
  end
  
  def read(n)
    __getobj__.read(n) if eof? # Make raise
    
    if pos + n > @bracket_to
      if @bufsize > n
        cache!(@bufsize)
      else
        cache!(n)
      end
    end
    
    @buf.read(n)
  end
  
  def pos
    @bracket_from + @buf.pos
  end
  
  def eof?
    @buf.eof? && __getobj__.eof?
  end
  
  def cache!(amount)
    @bracket_from = __getobj__.pos + @buf.pos # My complete position
    __getobj__.pos = @bracket_from
    @bracket_to = __getobj__.pos + amount
    @buf.string = __getobj__.read(amount)
  end
  
  def rewind
    @bracket_to = 0
    @buf.string = ''
    super
  end
end