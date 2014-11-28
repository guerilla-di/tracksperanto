# -*- encoding : utf-8 -*-
class Tracksperanto::Import::Syntheyes < Tracksperanto::Import::Base
  include Tracksperanto::UVCoordinates
  
  def self.human_name
    "Syntheyes \"Tracker 2-D paths\" file"
  end
  
  def self.known_snags
    "Syntheyes has two formats for exporting tracks. One is called \"Tracker 2-D paths\" in the menu. " +
    "The other is called \"All Tracker Paths\". This format you have selected corresponds to the " +
    "\"Tracker 2-D paths\", if something goes wrong might be a good idea to the other one one"
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
        e.abs_x = convert_from_uv(x, width)
        e.abs_y = height - convert_from_uv(y, height) # Convert TL to BL
      end
      
      @last_tracker.push(k)
      report_progress("Adding keyframe #{frame} to #{name}")
    end
    
    yield(@last_tracker) if @last_tracker && @last_tracker.any?
    
  end
end
