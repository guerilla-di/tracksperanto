
require 'bychar'

module Tracksperanto::ShakeGrammar
  class WrongInputError < RuntimeError; end
  
  # Since Shake uses a C-like language for it's scripts we rig up a very sloppy
  # but concise C-like lexer to cope
  class Lexer
    
    # Parsed stack
    attr_reader :stack
    
    # Access to the sentinel object
    attr_reader :sentinel
    
    STOP_TOKEN = :__stop #:nodoc:
    MAX_BUFFER_SIZE = 32000
    MAX_STACK_DEPTH = 127
    
    # The first argument is the IO handle to the data of the Shake script.
    # The second argument is a "sentinel" that is going to be passed
    # to the downstream lexers instantiated for nested data structures.
    # You can use the sentinel to collect data from child nodes for example.
    def initialize(with_io, sentinel = nil, limit_to_one_stmt = false, stack_depth = 0)
      # We parse byte by byte, but reading byte by byte is very slow. We therefore use a buffering reader
      # that will cache in chunks, and then read from there byte by byte.
      # This yields a substantial speedup (4.9 seconds for the test
      # as opposed to 7.9 without this). We do check for the proper class only once so that when we use nested lexers
      # we only wrap the passed IO once, and only if necessary.
      with_io = Bychar.wrap(with_io) unless with_io.respond_to?(:read_one_char)
      @io, @stack, @buf, @sentinel, @limit_to_one_stmt, @stack_depth  = with_io, [], '', sentinel, limit_to_one_stmt, stack_depth
      
      catch(STOP_TOKEN) do
        loop { parse }
      end
      
      @in_comment ? consume_comment! : consume_atom!
    end
    
    private
    
    def push_comment
      push [:comment, @buf.gsub(/(\s+?)\/\/{1}/, '')]
    end
    
    def consume_comment!
      push_comment
      erase_buffer
    end
    
    def parse
      
      if @buf.length > MAX_BUFFER_SIZE # Wrong format and the buffer is filled up, bail
        raise WrongInputError, "Atom buffer overflow at #{MAX_BUFFER_SIZE} bytes, this is definitely not a Shake script"
      end
      
      if @stack_depth > MAX_STACK_DEPTH # Wrong format - parentheses overload
        raise WrongInputError, "Stack overflow at level #{MAX_STACK_DEPTH}, this is probably a LISP program uploaded by accident"
      end
      
      c = @io.read_one_char
      throw :__stop if c.nil? # IO has run out
      
      if c == '/' && (@buf[-1].chr rescue nil) == '/' # Comment start
        # If some other data from this line has been accumulated we first consume that
        @buf = @buf[0..-2] # everything except the opening slash of the comment
        consume_atom!
        erase_buffer
        @in_comment = true
      elsif @in_comment && c == "\n" # Comment end
        consume_comment!
        @in_comment = false
      elsif @in_comment
        @buf << c
      elsif !@buf.empty? && (c == "(") # Funcall
        push([:funcall, @buf.strip] + self.class.new(@io, @sentinel, limit_to_one_stmt = false, @stack_depth + 1).stack)
        erase_buffer
      elsif c == '{' # OFX curly braces or a subexpression in a node's knob
        # Discard subexpr
        substack = self.class.new(@io, @sentinel, limit_to_one_stmt = true, @stack_depth + 1).stack
        push(:expr)
      elsif c == "[" # Array, booring
        push([:arr, self.class.new(@io).stack])
      elsif c == "}"# && @limit_to_one_stmt
        throw STOP_TOKEN
      elsif (c == "]" || c == ")" || c == ";" && @limit_to_one_stmt)
        # Bailing out of a subexpression
        consume_atom!
        throw STOP_TOKEN
      elsif (c == "," && @limit_to_one_stmt)
        consume_atom!
        throw STOP_TOKEN
      elsif (c == ",")
        consume_atom!
      elsif (c == "@")
        consume_atom!
        @buf << c
      elsif (c == ";" || c == "\n")
        # Skip these - the subexpression already is expanded anyway
      elsif (c == "=")
        vardef_atom = vardef(@buf.strip)
        push [:assign, vardef_atom, self.class.new(@io, @sentinel, limit_to_one_stmt = true, @stack_depth + 1).stack.shift]
        
        erase_buffer
      else
        @buf << c
      end
    end
    
    INT_ATOM = /^(\d+)$/
    FLOAT_ATOM = /^([\-\d\.]+)$/
    STR_ATOM = /^\"/
    AT_FRAME = /^@(-?\d+)/
    
    # Grab the minimum atomic value
    def consume_atom!
      at = @buf.strip
      erase_buffer
      return if at.empty?
      
      the_atom = case at
        when INT_ATOM
          at.to_i
        when STR_ATOM
          unquote_s(at)
        when FLOAT_ATOM
          at.to_f
        when AT_FRAME
          if $1.include?(".")
            [:value_at, $1.to_f, @stack.pop]
          else
            [:value_at, $1.to_i, @stack.pop]
          end
        else
          [:atom, at]
      end
      
      push(the_atom)
    end
    
    def unquote_s(string)
      string.strip.gsub(/^\"/, '').gsub(/\"$/, '').gsub(/\\\"/, '"')
    end
    
    # In the default impl. this just puts things on the stack. However,
    # if you want to unwrap structures as they come along (whych you do for big files)
    # you have to override this
    def push(atom_array)
      @stack << atom_array
    end
    
    def vardef(var_specifier)
      # Since we can have two-word pointers as typedefs (char *) we only use the last
      # part of the thing as varname. Nodes return the :image type implicitly.
      varname_re = /\w+$/
      varname = var_specifier.scan(varname_re).flatten.join
      typedef = var_specifier.gsub(varname_re, '').strip
      typedef = :image if typedef.empty?
      
      [:vardef, typedef, varname]
    end
    
    def erase_buffer
      @buf = ''
    end
  end
end
