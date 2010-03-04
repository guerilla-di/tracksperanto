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
  
  def <<(some_verbatim_string)
    some_verbatim_string.split("\n").each do | line |
      @io.puts(["\t" * @indent, line].join)
    end
  end
  
  private
  
  def method_missing(meth, arg = nil)
    if block_given?
      method_body = "def #{meth}(v);"+                          #  def foo(v)
        "write_block!(#{meth.inspect}, v){|c| yield(c)};"+      #    write_block!("foo", v) {|c| yield(c) }
      "end"                                                     #  end
      self.class.send(:class_eval, method_body)
      write_block!(meth, arg) {|c| yield(c) }
    else
      if arg.nil?
        method_body = "def #{meth};"+                          #  def foo
          "write_loose!(#{meth.inspect});"+                    #    write_loose!("foo")
        "end"                                                  #  end
        self.class.send(:class_eval, method_body)
        write_loose!(meth)
      else
        method_body = "def #{meth}(v);"+                       #  def foo(bar)
          "write_tuple!(#{meth.inspect}, v);"+                 #    write_tuple!("foo", bar)
        "end"                                                  #  end
        self.class.send(:class_eval, method_body)
        write_tuple!(meth, arg)
      end
    end
  end
  
  def __camelize(s)
    @@camelizations ||= {}
    @@camelizations[s] ||= s.to_s.gsub(/(^|_)(.)/) { $2.upcase }
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