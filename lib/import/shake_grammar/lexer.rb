module Tracksperanto::ShakeGrammar
  # Since Shake uses a C-like language for it's scripts we rig up a very sloppy
  # but concise C-like lexer to cope
  class Lexer
    
    attr_reader :stack
    
    def initialize(with_io)
      @io, @stack, @buf  = with_io, [], ''
      parse until (@io.eof? || @stop)
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
        push([:funcall, @buf.strip] + self.class.new(@io).stack)
        @buf = ''
      elsif c == "[" # Array, booring
        push([:arr] + self.class.new(@io).stack)
      elsif (c == "]" || c == ")")
        # Funcall end, and when it happens assume we are called as
        # a subexpression.
        consume_atom!
        @stop = true
      elsif (c == ",")
        consume_atom!
      elsif (c == ";" || c == "\n")
        # Skip these - the subexpression already is expanded anyway
      elsif (c == "=")
        push [:var, @buf.strip]
        push [:eq]
        @buf = ''
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
    
    # Grab the minimum atomic value
    def consume_atom!
      at, @buf = @buf.strip, ''
      return if at.empty?
      
      the_atom = case at
        when INT_ATOM
          [:atom_i, at.to_i]
        when STR_ATOM
          [:atom_c, unquote_s(at)]
        when FLOAT_ATOM
          [:atom_f, at.to_f]
        when AT_ATOM
          v, f = at.strip.split("@")
          [[:atom_f, v.to_f], [:atom_at_i, f.to_i]]
        when AT_CONSUMED
          [:atom_at_i, $1.to_i]
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