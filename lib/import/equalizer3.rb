# Imports 3D Equalizer's text files, version 3
class Tracksperanto::Import::Equalizer3 < Tracksperanto::Import::Base
  
  def self.human_name
    "3DE v3 point export file"
  end
  
  def self.autodetects_size?
    true
  end
  
  def each
    io = Tracksperanto::ExtIO.new(@io)
    detect_format!(io)
    extract_trackers(io) {|t| yield(t) }
  end
  
  private
    
    def detect_format!(io)
      first_line = io.gets_non_empty
      self.width, self.height = first_line.scan(/(\d+) x (\d+)/).flatten
    end
    
    def extract_trackers(io)
      while line = io.gets do
        if line =~ /^(\w+)/ # Tracker name
          yield(@last_tracker) if @last_tracker && @last_tracker.any?
          @last_tracker = Tracksperanto::Tracker.new(:name => line.strip)
          report_progress("Capturing tracker #{line.strip}")
        elsif line =~ /^\t/
          @last_tracker.keyframe!(make_keyframe(line))
        end
      end
      
      yield(@last_tracker) if @last_tracker && @last_tracker.any?
    end
    
    def make_keyframe(from_line)
      frame, x, y = from_line.split
      report_progress("Capturing keyframe #{frame}")
      {:frame => (frame.to_i - 1), :abs_x => x, :abs_y => y}
    end
end