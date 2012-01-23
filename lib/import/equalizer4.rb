# -*- encoding : utf-8 -*-
# Imports 3D Equalizer's text files
class Tracksperanto::Import::Equalizer4 < Tracksperanto::Import::Base
  
  def self.human_name
    "3DE v4 point export file"
  end
  
  def each
    io = Tracksperanto::ExtIO.new(@io)
    num_t = detect_num_of_points(io)
    num_t.times { yield(extract_tracker(io)) }
  end
  
  private
    
    def detect_num_of_points(io)
      io.gets_non_empty.to_i
    end
    
    KF_PATTERN = /^(\d+)\s([\-\d\.]+)\s([\-\d\.]+)/
    def extract_tracker(io)
      t = Tracksperanto::Tracker.new(:name => io.gets.strip)
      
      report_progress("Capturing tracker #{t.name}")
      
      io.gets # Tracker color, internal 3DE repr and 0 is Red
      
      num_of_keyframes = io.gets.to_i
      catch(:__emp) do
        num_of_keyframes.times do
          line = io.gets_non_empty
          throw :__emp unless line
          
          frame, x, y = line.scan(KF_PATTERN).flatten
          report_progress("Capturing keyframe #{frame}")
          t.keyframe!(:frame => (frame.to_i - 1), :abs_x => x, :abs_y => y)
        end
      end
      t
    end
end
