# An Enumerable wrapper that will only yield non-empty elements
class Tracksperanto::YieldNonEmpty
  
  include Enumerable
  
  def initialize(obj)
    @obj = obj
  end
  
  def each
    @obj.each do | item |
      yield(item) unless item.empty?
    end
  end
end