class Tracksperanto::Import::PFTrack < Tracksperanto::Import::Base
  def parse(file_content)
    trackers = []
    io = StringIO.new(file_content)
    until io.eof?
      line = io.gets
      next unless line
      
      if line =~ /[AZaz]/ # Tracker with a name
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
      num_of_keyframes = io.gets.chomp.to_i
      t.keyframes = (1..num_of_keyframes).map do
        report_progress("Reading keyframe")
        Tracksperanto::Keyframe.new do |k| 
          k.frame, k.abs_x, k.abs_y, k.residual = io.gets.chomp.split
        end
      end
    end
end