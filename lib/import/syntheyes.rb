class Tracksperanto::Import::Syntheyes < Tracksperanto::Import::Base
  
  def self.human_name
    "Syntheyes tracker export (UV) file"
  end
  
  def parse(io)
    trackers = []
    io.each_line do | line |
      name, frame, x, y, frame_status = line.split
      
      # Do we already have this tracker?
      t = trackers.find {|e| e.name == name}
      if !t
        report_progress("Allocating tracker #{name}")
        t = Tracksperanto::Tracker.new{|t| t.name = name }
        trackers << t
      end
      
      # Add the keyframe
      t.keyframes << Tracksperanto::Keyframe.new do |e| 
        e.frame = frame
        e.abs_x = convert_from_uv(width, x)
        e.abs_y = height - convert_from_uv(height, y) # Convert TL to BL
      end
      report_progress("Adding keyframe #{frame} to #{name}")
    end
    
    trackers
  end
  
  private
    # Syntheyes exports UV coordinates that go from -1 to 1, up and right and 0
    # is the center
    def convert_from_uv(absolute_side, uv_value)
      # First, start from zero (-.1 becomes .4)
      value_off_corner = (uv_value.to_f / 2) + 0.5
      absolute_side * value_off_corner
    end
end