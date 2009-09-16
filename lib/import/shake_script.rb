require 'strscan'

class Tracksperanto::Import::ShakeScript < Tracksperanto::Import::Base
  
  # Since Shake uses a C-like language for it's scripts we rig up a very sloppy
  # but concise C-like lexer to cope
  class Lexer
    
    END_SUBEXPR = :___ESX
    
    attr_reader :stack
    
    def initialize(with_io)
      @io, @stack, @buf  = with_io, [], ''
      catch(END_SUBEXPR) do
        parse until @io.eof?
      end
      in_comment? ? consume_comment("\n") : consume_atom!
    end
    
    private
    
    def in_comment?
      (@buf.strip =~ /^\/\//) ? true : false
    end
    
    def buf_has_data?
      @buf.strip.empty?
    end
    
    def consume_comment(c)
      if c == "\n" # Comment
        push [:comment, @buf.gsub(/(\s+?)\/\/{1}/, '')]
        clear_buffer
      else
        @buf << c
      end
    end
    
    def clear_buffer
      @buf = ''
    end
    
    def parse
      c = @io.read(1)
      return consume_comment(c) if in_comment? 
      
      if !@buf.empty? && (c == "(") # Funcall
        push([:funcall, @buf.strip] + self.class.new(@io).stack)
        clear_buffer
      elsif c == "[" # Array, booring
        push([:arr] + self.class.new(@io).stack)
      elsif (c == "]" || c == ")")
        # Funcall end, and when it happens assume we are called as
        # a subexpression.
        consume_atom!
        throw END_SUBEXPR
      elsif (c == ",")
        consume_atom!
      elsif (c == ";")
        # Skip this one, since the subexpression already is expanded anyway
      elsif (c == "\n")
        # Skip too
      elsif (c == "=")
        handle_assignment
      else
        @buf << c
      end
    end
    
    INT_ATOM = /^(\d+)$/
    FLOAT_ATOM = /^([\-\d\.]+)$/
    STR_ATOM = /^\"/
    AT_ATOM = /^([\-\d\.]+)@([\-\d\.]+)$/
    AT_CONSUMED = /^@(\d+)/
    VAR_ASSIGN = /^([\w_]+)(\s+?)\=(\s+?)(.+)/
    
    def handle_assignment
      push [:var, @buf.strip]
      push [:eq]
      clear_buffer
    end
    
    # Grab the minimum atomic value
    def consume_atom!
      at = @buf
      @buf = ''
      return if at.strip.empty?
      
      the_atom = if at.strip =~ INT_ATOM
        [:atom_i, at.to_i]
      elsif at.strip =~ STR_ATOM
        [:atom_c, unquote_s(at)]
      elsif at.strip =~ FLOAT_ATOM
        [:atom_f, at.to_f]
      elsif at.strip =~ AT_ATOM
        v, f = at.strip.split("@")
        [[:atom_f, v.to_f], [:atom_at_i, f.to_i]]
      elsif at.strip =~ AT_CONSUMED
        [:atom_at_i, $1.to_i]
      elsif at.strip =~ VAR_ASSIGN
        [:equals, $1]
      elsif at.strip.empty?
        # whitespace :-)
      else
        [:atom, at]
      end
      
      push(the_atom) unless the_atom.nil?
    end
    
    def unquote_s(string)
      string.strip.gsub(/^\"/, '').gsub(/\"$/, '').gsub(/\\\"/, '"')
    end
    
    def push(atom_array)
      @stack << atom_array
    end
  end
  
  # Will replay funcalls through to methods if such methods exist in the public insntance
  class Catcher < Lexer
    
    def push(atom_array)
      atom_name = atom_array[0]
      if atom_name == :funcall
        func, funcargs = atom_array[1], atom_array[2..-1]
        meth_for_shake_func = func.downcase
        if self.class.public_instance_methods(false).include?(meth_for_shake_func)
          super([:retval, exec_funcall(meth_for_shake_func, funcargs)])
        else
          super
        end
      else
        super
      end
    end
    
    private
    
    def exec_funcall(methname, args)
      ruby_args = unwrap_args(args)
      send(*ruby_args.unshift(methname))
    end
    
    def unwrap_args(args)
      args.map do | arg |
        arg.is_a?(Array) ? unwrap_atom(arg) : arg
      end
    end
    
    def unwrap_atom(atom)
      kind = atom.shift
      case kind
        when :retval, :atom_i, :atom_c, :atom_f
          atom.shift
        else
          :unknown
      end
    end
  
  end
  
  def parse(script_io)
  end
end