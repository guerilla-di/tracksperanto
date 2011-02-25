class Tracksperanto::Import::Syntheyes < Tracksperanto::Import::Base
  include Tracksperanto::UVCoordinates
  
  def self.human_name
    "Syntheyes 2D tracker paths file"
  end
  
  def each
    @io.each_line do | line |
      name, frame, x, y, frame_status = line.split
      
      # Do we already have this tracker?
      unless @last_tracker && @last_tracker.name == name
        yield(@last_tracker) if @last_tracker
        report_progress("Allocating tracker #{name}")
        @last_tracker = Tracksperanto::Tracker.new{|t| t.name = name }
      end
      
      # Add the keyframe
      k = Tracksperanto::Keyframe.new do |e| 
        e.frame = frame
        e.abs_x = convert_from_uv(width, x)
        e.abs_y = height - convert_from_uv(height, y) # Convert TL to BL
      end
      
      @last_tracker.push(k)
      report_progress("Adding keyframe #{frame} to #{name}")
    end
    yield(@last_tracker) if @last_tracker && @last_tracker.any?
    
  end
end