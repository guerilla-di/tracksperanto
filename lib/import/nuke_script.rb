require 'delegate'

class Tracksperanto::Import::NukeScript < Tracksperanto::Import::Base
  
  
  T = ::Tracksperanto::Tracker
  K = ::Tracksperanto::Keyframe
  
  # Nuke files are extensively indented and indentation is significant.
  # We use this to always strip the lines we process since we capture before
  # indentation becomes crucial
  class IOC < DelegateClass(IO)
    def initialize(h)
      __setobj__(h)
    end
    
    def gets_and_strip
      s = __getobj__.gets
      s ? s.strip : nil
    end
  end
  
  def parse(nuke_script_content)
    
    io = StringIO.new(nuke_script_content)
    scan_for_tracker3_nodes(IOC.new(io))
  end
  
  private
    
    TRACKER_3_PATTERN = /^Tracker3 \{/
    TRACK_PATTERN = /^track(\d) \{/
    NODENAME = /^name ([^\n]+)/
    
    def scan_for_tracker3_nodes(io)
      tracks = []
      while line = io.gets_and_strip
        tracks << scan_tracker_node(io) if line =~ TRACKER_3_PATTERN
      end
      tracks.flatten
    end
    
    def scan_tracker_node(io)
      tracks_in_tracker = []
      while line = io.gets_and_strip
        if line =~ TRACK_PATTERN
          tuples = scan_track(line)
          tracks_in_tracker.push(
            T.new(:keyframes => tuples.map { | (f, x, y) | K.new(:frame => f -1, :abs_x => x, :abs_y => y) })
          )
        elsif line =~ NODENAME
          tracks_in_tracker.each_with_index do | t, i |
            t.name = "#{$1}_track#{i+1}"
          end
          return tracks_in_tracker
        end
      end
      raise "Tracker node went all the way to end of stream"
    end
    
    def scan_track(line_with_curve)
      x_curve, y_curve = line_with_curve.split(/\}/).map{ | one_curve| parse_curve(one_curve) }
      zip_curve_tuples(x_curve, y_curve)
    end
    
    # Scan a curve to a number of triplets
    def parse_curve(curve_text)
      # Replace the closing curly brace with a curly brace with space so that it gets caught by split
      atoms, tuples = curve_text.gsub(/\}/, ' }').split, []
      section_start = /^x(\d+)$/
      keyframe = /^([-\d\.]+)$/
      
      last_processed_keyframe = 1
      while atom = atoms.shift
        if atom =~ section_start
          last_processed_keyframe = $1.to_i
        elsif  atom =~ keyframe
          tuples << [last_processed_keyframe, $1.to_f]
          last_processed_keyframe += 1
        elsif atom == '}'
          return tuples
        end
      end
      tuples
    end
    
    # Zip two channel objects to tuples of [frame, valuex, valuey] 
    # skipping keyframes that do not match in the two
    def zip_curve_tuples(a, b)
      tuples = []
      
      a.each do | keyframe |
        tuples[keyframe[0]] = [keyframe[0], keyframe[1]]
      end
      
      b.each do | keyframe |
        tuples[keyframe[0]] = (tuples[keyframe[0]] << keyframe[1]) if tuples[keyframe[0]]
      end
      
      tuples.compact.reject{|e| e.length < 3 }
    end
end