# Imports 3D Equalizer's text files
class Tracksperanto::Import::Equalizer < Tracksperanto::Import::Base
  
  def self.human_name
    "3DE point export file"
  end
  
  
  def parse(passed_io)
    ts = []
    io = Tracksperanto::ExtIO.new(passed_io)
    
    num_t = detect_num_of_points(io)
    num_t.times { ts << extract_tracker(io) }
    
    ts
  end
  
  private
    
    def detect_num_of_points(io)
      io.gets_non_empty.to_i
    end
    
    KF_PATTERN = /^(\d+)\s([\-\d\.]+)\s([\-\d\.]+)/
    def extract_tracker(io)
      t = Tracksperanto::Tracker.new(:name => io.gets.strip)
      
      io.gets # Tracker color, internal 3DE repr and 0 is Red
      
      num_of_keyframes = io.gets.to_i
      catch(:__emp) do
        num_of_keyframes.times do
          line = io.gets_non_empty
          throw :__emp unless line
          
          frame, x, y = line.scan(KF_PATTERN).flatten
          t.keyframe!(:frame => (frame.to_i - 1), :abs_x => x, :abs_y => y)
        end
      end
      t
    end
end