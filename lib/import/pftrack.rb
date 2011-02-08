class Tracksperanto::Import::PFTrack < Tracksperanto::Import::Base
  def self.human_name
    "PFTrack/PFMatchit .2dt file"
  end
  
  def self.distinct_file_ext
    ".2dt"
  end
  
  CHARACTERS_OR_QUOTES = /[AZaz"]/
  INTS = /^\d+$/
  
  def stream_parse(io)
    until io.eof?
      line = io.gets
      next if (!line || line =~ /^#/)
      
      if line =~ CHARACTERS_OR_QUOTES # Tracker with a name
        t = Tracksperanto::Tracker.new{|t| t.name = unquote(line.strip) }
        report_progress("Reading tracker #{t.name}")
        parse_tracker(t, io)
        send_tracker(t)
      end
    end
  end
  
  private
    def parse_tracker(t, io)
      first_tracker_line = io.gets.chomp
      
      # We will be reading one line too many possibly, so we need to know
      # where to return to in case we do
      first_data_offset = io.pos
      second_tracker_line = io.gets.chomp
      
      # Camera name in version 5 format, might be integer might be string
      if first_tracker_line =~ CHARACTERS_OR_QUOTES || second_tracker_line =~ INTS
        # Add cam name to the tracker
        t.name += ("_%s" % unquote(first_tracker_line))
        num_of_keyframes = second_tracker_line.to_i
      else
        num_of_keyframes = first_tracker_line.to_i
        # Backtrack to where we were on this IO so that the first line read will be the tracker
        report_progress("Backtracking to the beginning of data block")
        io.seek(first_data_offset)
      end
      
      (1..num_of_keyframes).map do | keyframe_idx |
        report_progress("Reading keyframe #{keyframe_idx} of #{num_of_keyframes} in #{t.name}")
        f, x, y, residual = io.gets.chomp.split
        t.keyframe!(:frame => f, :abs_x => x, :abs_y => y, :residual => residual.to_f * 8)
      end
    end
    
    def unquote(s)
      s.gsub(/"/, '')
    end
end