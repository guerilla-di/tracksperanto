# Imports 3D Equalizer's text files, version 3
class Tracksperanto::Import::Equalizer3 < Tracksperanto::Import::Base
  
  def self.human_name
    "3DE v3 point export file"
  end
  
  def self.autodetects_size?
    true
  end
  
  def parse(passed_io)
    io = Tracksperanto::ExtIO.new(passed_io)
    
    detect_format!(io)
    extract_trackers(io)
  end
  
  private
    
    def detect_format!(io)
      first_line = io.gets_non_empty
      self.width, self.height = first_line.scan(/(\d+) x (\d+)/).flatten
    end
    
    def extract_trackers(io)
      ts = []
      while line = io.gets do
        if line =~ /^(\w+)/ # Tracker name
          discard_last_empty_tracker!(ts)
          ts.push(Tracksperanto::Tracker.new(:name => line.strip))
          report_progress("Capturing tracker #{line.strip}")
        elsif line =~ /^\t/
          ts[-1].push(make_keyframe(line))
        end
      end
      
      discard_last_empty_tracker!(ts)
      ts
    end
    
    def discard_last_empty_tracker!(in_array)
      if (in_array.any? && in_array[-1].empty?)
        in_array.delete_at(-1)
        report_progress("Removing the last tracker since it had no keyframes")
      end
    end
    
    def make_keyframe(from_line)
      frame, x, y = from_line.split
      report_progress("Capturing keyframe #{frame}")
      Tracksperanto::Keyframe.new(:frame => (frame.to_i - 1), :abs_x => x, :abs_y => y)
    end
end