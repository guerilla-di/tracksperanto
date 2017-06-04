# Many importers use this as a standard. This works like a wrapper for any
# IO object with a couple extra methods added. Note that if you use this in an
# importer you need to wrap the incoming input with it yourself (that is, an IO passed
# to the import module will NOT be wrapped into this already)
# 
#  io = ExtIO.new(my_open_file)
#  io.gets_non_empty #=> "This is the first line after 2000 linebreaks"
class Tracksperanto::ExtIO < Tracksperanto::IOWrapper
  def initialize(with)
    @backing_buffer = with
  end
  
  # Similar to IO#gets however it will also strip the returned result. This is useful
  # for doing
  #   while non_empty_str = io.gets_and_strip
  # because you don't have to check for io.eof? all the time or see if the string is not nil
  def gets_and_strip
    s = gets
    s ? s.strip : nil
  end
  
  # Similar to IO#gets but it skips empty lines and the first line returned will actually contain something 
  def gets_non_empty
    until eof?
      line = gets
      return nil if line.nil?
      s = line.strip
      return s unless s.empty?
    end
  end
end
