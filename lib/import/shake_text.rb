# Import for Shake Text files
class Tracksperanto::Import::ShakeText < Tracksperanto::Import::Base
  
  def self.human_name
    "Shake .txt tracker file"
  end
  
  def stream_parse(io)
    io.each do | line |
      if line =~ /TrackName (.+)/
        send_tracker(@last_tracker) if @last_tracker && @last_tracker.any?
        @last_tracker = Tracksperanto::Tracker.new(:name => $1)
        # Toss the next following string - header
        io.gets
      else
        keyframe_values = line.split
        next if keyframe_values.length < 4
        
        @last_tracker.keyframe!(
          :frame => (keyframe_values[0].to_i - 1),
          :abs_x => keyframe_values[1],
          :abs_y => keyframe_values[2],
          :residual => (1 - keyframe_values[3].to_f)
        )
      end
    end
    
    send_tracker(@last_tracker) if @last_tracker && @last_tracker.any?
  end
  
end