class Tracksperanto::Import::Syntheyes < Tracksperanto::Import::Base
  include Tracksperanto::UVCoordinates
  
  def self.human_name
    "Syntheyes 2D tracker paths file"
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

end