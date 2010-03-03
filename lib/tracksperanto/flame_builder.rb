# A Builder-like class for exporting Flame setups
class Tracksperanto::FlameBuilder
  INDENT = "\t"
  
  
  def initialize(io, indent = 0)
    @io, @indent = io, indent
  end
  
  def write_block!(name, value = nil, &blk)
    value.nil? ? write_loose!(name) : write_tuple!(name, value)
    yield(self.class.new(@io, @indent + 1))
    @io.puts(INDENT * (@indent + 1) + "End")
  end
  
  def write_tuple!(key, value)
    @io.puts("%s%s %s" % [INDENT * @indent, __camelize(key), __flameize(value)])
  end
  
  def write_loose!(value)
    @io.puts("%s%s" % [INDENT * @indent, __camelize(value)])
  end
  
  def linebreak!(how_many = 1)
    @io.write("\n" * how_many)
  end
  
  def color_hash!(name, red, green, blue)
    write_loose!(name)
    n = self.class.new(@io, @indent + 1)
    n.red(red)
    n.green(green)
    n.blue(blue)
  end
  
  private
  
  def method_missing(meth, arg = nil)
    self.class.send(:alias_method, meth, :__generic)
    if block_given?
      __generic(meth, arg) {|*a| yield(*a) if block_given? }
    else
      __generic(meth, arg)
    end
  end
  
  def __generic(meth, arg = nil)
    if block_given?
      write_block!(meth, arg) { |c| yield(c) }
    else
      arg.nil? ? write_loose!(meth) : write_tuple!(meth, arg)
    end
  end
  
  def __camelize(s)
    s.to_s.gsub(/(^|_)(.)/) { $2.upcase }
  end
  
  def __flameize(v)
    case v
      when Float
        "%.3f" % v
      when TrueClass
        "yes"
      when FalseClass
        "no"
      else
        v.to_s
    end
  end
end