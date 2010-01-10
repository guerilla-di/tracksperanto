module Tracksperanto::ShakeGrammar
  # Will replay funcalls through to methods if such methods exist in the public insntance
  class Catcher < Lexer
  
    def push(atom_array)
      atom_name = atom_array[0]
      if atom_name == :funcall
        func, funcargs = atom_array[1], atom_array[2..-1]
        meth_for_shake_func = func.downcase
        if can_handle_meth?(meth_for_shake_func)
          super([:retval, exec_funcall(meth_for_shake_func, funcargs)])
        else
          # This is a funcall we cannot perform, replace the return result of the funcall
          # with a token to signify that some unknown function's result would have been here
          super(:unknown_func)
        end
      elsif atom_name == :comment
        # Skip comments
      else
        super
      end
    end
    
    private
    
    def get_variable_name
      @stack[-2][1]
    end
    
    def can_handle_meth?(m)
      @meths ||= self.class.public_instance_methods(false)
      @meths.include?(m)
    end
    
    def exec_funcall(methname, args)
      ruby_args = unwrap_atoms_in_args(args)
      send(methname, *ruby_args)
    end
    
    def unwrap_atoms_in_args(args)
      args.map do | arg |
        (arg.is_a?(Array) && arg[0].is_a?(Symbol)) ? unwrap_atom(arg) : arg
      end
    end
    
    def unwrap_atom(atom)
      kind = atom.shift
      case kind
        when :arr
          atom.map{|e| unwrap_atom(e)}
        when :retval, :atom_i, :atom_c, :atom_f, :atom_at_i, :atom_at_f
          atom.shift
        else
          :unknown
      end
    end

  end
end