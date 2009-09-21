class Tracksperanto::Import::PFTrack < Tracksperanto::Import::Base
  def self.human_name
    "PFTrack .2dt file"
  end
  
  def self.distinct_file_ext
    ".2dt"
  end
  
  CHARACTERS = /[AZaz]/
  
  def parse(io)
    trackers = []
    until io.eof?
      line = io.gets
      next if (!line || line =~ /^#/)
      
      if line =~ CHARACTERS # Tracker with a name
        t = Tracksperanto::Tracker.new{|t| t.name = line.strip.gsub(/"/, '') }
        report_progress("Reading tracker #{t.name}")
        parse_tracker(t, io)
        trackers << t
      end
    end
    
    trackers
  end
  
  private
    def parse_tracker(t, io)
      first_tracker_line = io.gets.chomp
      
      if first_tracker_line =~ CHARACTERS # PFTrack version 5 format
        first_tracker_line = io.gets.chomp
      end
      
      num_of_keyframes = first_tracker_line.to_i
      t.keyframes = (1..num_of_keyframes).map do
        report_progress("Reading keyframe")
        Tracksperanto::Keyframe.new do |k| 
          k.frame, k.abs_x, k.abs_y, k.residual = io.gets.chomp.split
        end
      end
    end
end