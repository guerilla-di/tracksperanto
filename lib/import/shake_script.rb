require File.dirname(__FILE__) + "/shake_grammar/lexer"
require File.dirname(__FILE__) + "/shake_grammar/catcher"

class Tracksperanto::Import::ShakeScript < Tracksperanto::Import::Base
  include Tracksperanto::ShakeGrammar
  
  def parse(script_io)
    
    []
  end
end