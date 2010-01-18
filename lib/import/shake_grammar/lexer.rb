module Tracksperanto::ShakeGrammar
  # Since Shake uses a C-like language for it's scripts we rig up a very sloppy
  # but concise C-like lexer to cope
  class Lexer
    
    # Parsed stack
    attr_reader :stack
    
    # Access to the sentinel object
    attr_reader :sentinel
    
    STOP_TOKEN = :__stop #:nodoc:
    
    # The first argument is the IO handle to the data of the Shake script.
    # The second argument is a "sentinel" that is going to be passed
    # to the downstream lexers instantiated for nested data structures.
    # You can use the sentinel to collect data from child nodes for example.
    def initialize(with_io, sentinel = nil, limit_to_one_stmt = false)
      @io, @stack, @buf, @sentinel, @limit_to_one_stmt  = with_io, [], '', sentinel, @limit_to_one_stmt
      catch(STOP_TOKEN) { parse until @io.eof? }
      in_comment? ? consume_comment("\n") : consume_atom!
    end
    
    private
    
    def in_comment?
      (@buf.strip =~ /^\/\//) ? true : false
    end
    
    def consume_comment(c)
      if c == "\n" # Comment
        push [:comment, @buf.gsub(/(\s+?)\/\/{1}/, '')]
        @buf = ''
      else
        @buf << c
      end
    end
    
    def parse
      c = @io.read(1)
      return consume_comment(c) if in_comment? 
      
      if !@buf.empty? && (c == "(") # Funcall
        push([:funcall, @buf.strip] + self.class.new(@io, @sentinel).stack)
        @buf = ''
      elsif c == "[" # Array, booring
        push([:arr, self.class.new(@io).stack])
      elsif (c == "]" || c == ")" || c == ";" && @limit_to_one_stmt)
        # Bailing out of a subexpression
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
        push [:assign, @buf.strip, self.class.new(@io, @sentinel, to_semicolon = true).stack.shift]
        @buf = ''
      else
        @buf << c
      end
    end
    
    INT_ATOM = /^(\d+)$/
    FLOAT_ATOM = /^([\-\d\.]+)$/
    STR_ATOM = /^\"/
    AT_FRAME = /^@(\d+)/
    
    # Grab the minimum atomic value
    def consume_atom!
      at, @buf = @buf.strip, ''
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
    
    def push(atom_array)
      @stack << atom_array
    end
  end
end