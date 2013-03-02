# -*- encoding : utf-8 -*-
class Tracksperanto::NukeGrammarUtils
  SECTION_START = /^x(\d+)$/
  KEYFRAME = /^([-\d\.]+)$/
  
  # Scan a TCL curve expression into a number of tuples of [frame, value]
  def parse_curve(atoms)
    # Replace the closing curly brace with a curly brace with space so that it gets caught by split
    atoms.shift # remove the "curve" keyword
    tuples = []
    # Nuke saves curves very efficiently. x(keyframe_number) means that an uninterrupted sequence of values will start,
    # after which values follow. When the curve is interrupted in some way a new x(keyframe_number) will signifu that we
    # skip to that specified keyframe and the curve continues from there, in gap size defined by the last fragment.
    # That is, x1 1 x3 2 3 4 will place 2, 3 and 4 at 2-frame increments
    
    last_processed_keyframe = 1
    intraframe_gap_size = 1
    while atom = atoms.shift
      if atom =~ SECTION_START
        last_processed_keyframe = $1.to_i
        if tuples.any?
          last_captured_frame = tuples[-1][0]
          intraframe_gap_size = last_processed_keyframe - last_captured_frame
        end
      elsif  atom =~ KEYFRAME
        tuples << [last_processed_keyframe, $1.to_f]
        last_processed_keyframe += intraframe_gap_size
      end
    end
    tuples
  end
end
