module Tracksperanto::ShakeGrammar
  # Will replay funcalls through to methods if such methods exist in the public insntance
  class Catcher < Lexer
    class At
      attr_accessor :at, :value
      include Comparable
      def initialize(a, v)
        @at, @value = a, v
      end
      
      def <=>(o)
        [@at, @value] <=> [o.at, o.value]
      end
      
      def inspect
        "(#{@value.inspect}@#{@at.inspect})"
      end
    end
    
    def push(atom)
      
      # Send everything but funcalls to parent
      return super unless atom.is_a?(Array) && atom[0] == :funcall
      
      meth_for_shake_func, args = atom[1].downcase, atom[2..-1]
      if can_handle_meth?(meth_for_shake_func)
        super([:retval, exec_funcall(meth_for_shake_func, args)])
      else
        # This is a funcall we cannot perform, replace the return result of the funcall
        # with a token to signify that some unknown function's result would have been here
        super([:unknown_func])
      end
    end
    
    private
    
    # Suppress comment output
    def push_comment
    end
    
    def can_handle_meth?(m)
      # Ruby 1.9 - match on stringified methname
      @meths ||= self.class.public_instance_methods(false).map{|mn| mn.to_s }
      @meths.include?(m.to_s)
    end
    
    def exec_funcall(methname, args)
      ruby_args = args.map {|a| unwrap_atom(a) }
      send(methname, *ruby_args)
    end
    
    def unwrap_atom(atom)
      return atom unless atom.is_a?(Array)
      
      kind = atom.shift
      case kind
        when :arr
          atom[0].map{|e| unwrap_atom(e)}
        when :retval
          atom.shift
        when :value_at
          At.new(atom.shift, unwrap_atom(atom.shift))
        else
          :unknown
      end
    end

  end
end
