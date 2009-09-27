# Many importers use this as a standard. This works like a wrapper for any
# IO object with a couple extra methods added
class Tracksperanto::ExtIO < DelegateClass(IO)
  def initialize(with)
    __setobj__ with
  end
  
  def gets_and_strip
    s = __getobj__.gets
    s ? s.strip : nil
  end
  
  def gets_non_empty
    line = __getobj__.gets
    return nil if line.nil?
    s = line.strip
    return gets_non_empty if s.empty?
    s
  end
end