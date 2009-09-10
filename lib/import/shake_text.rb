require 'stringio'

class Tracksperanto::Import::ShakeText < Tracksperanto::Import::Base
  
  def self.human_name
    "Shake .txt tracker file"
  end
  
  def parse(io)
    trackers = []
    until io.eof?
      line = io.gets
      if line =~ /TrackName (.+)/
        trackers << Tracksperanto::Tracker.new{|t| t.name = $1 }
        # Toss the next following string - header
        io.gets
      else
        keyframe_values = line.split
        next if keyframe_values.length < 4
        
        trackers[-1].keyframes << Tracksperanto::Keyframe.new do | kf |
          kf.frame = (keyframe_values[0].to_i - 1)
          kf.abs_x = keyframe_values[1]
          kf.abs_y = keyframe_values[2]
          kf.residual = (1 - keyframe_values[3].to_f)
        end
      end
    end
    
    trackers
  end
end