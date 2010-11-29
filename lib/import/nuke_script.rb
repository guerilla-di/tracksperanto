require 'delegate'

class Tracksperanto::Import::NukeScript < Tracksperanto::Import::Base
  
  def self.human_name
    "Nuke .nk script file"
  end
  
  def self.distinct_file_ext
    ".nk"
  end
  
  def stream_parse(in_io)
    io = Tracksperanto::ExtIO.new(in_io)
    while line = io.gets_and_strip
      if line =~ TRACKER_3_PATTERN
        scan_tracker_node(io).each { |t| send_tracker(t) }
      end
    end
    
  end
  
  private
    
    TRACKER_3_PATTERN = /^Tracker3 \{/
    TRACK_PATTERN = /^track(\d) \{/
    NODENAME = /^name ([^\n]+)/
    
    
    def scan_tracker_node(io)
      tracks_in_tracker = []
      while line = io.gets_and_strip
        if line =~ TRACK_PATTERN
          t = extract_tracker(line)
          tracks_in_tracker.push(t) if t
        elsif line =~ NODENAME
          tracks_in_tracker.each_with_index do | t, i |
            t.name = "#{$1}_track#{i+1}"
            report_progress("Scavenging Tracker3 node #{t.name}")
          end
          return tracks_in_tracker
        end
      end
      raise "Tracker node went all the way to end of stream"
    end
    
    def scan_track(line_with_curve)
      x_curve, y_curve = line_with_curve.split(/\}/).map{ | one_curve| parse_curve(one_curve) }
      return nil unless (x_curve && y_curve)
      zip_curve_tuples(x_curve, y_curve)
    end
    
    SECTION_START = /^x(\d+)$/
    KEYFRAME = /^([-\d\.]+)$/
    
    # Scan a curve to a number of tuples of [frame, value]
    def parse_curve(curve_text)
      # Replace the closing curly brace with a curly brace with space so that it gets caught by split
      atoms, tuples = curve_text.gsub(/\}/m, ' }').split, []
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
          report_progress("Reading curve at frame #{last_processed_keyframe}")
          tuples << [last_processed_keyframe, $1.to_f]
          last_processed_keyframe += intraframe_gap_size
        elsif atom == '}'
          return tuples
        end
      end
      tuples
    end
    
    def extract_tracker(line)
      tuples = scan_track(line)
      return nil unless (tuples && tuples.any?)
      
      Tracksperanto::Tracker.new(
        :keyframes => tuples.map do | (f, x, y) | 
          Tracksperanto::Keyframe.new(:frame => f -1, :abs_x => x, :abs_y => y) 
        end
      )
    end
end