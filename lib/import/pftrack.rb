# TODO: this should be rewritten as a proper state-machine parser
class Tracksperanto::Import::PFTrack < Tracksperanto::Import::Base
  
  include Tracksperanto::PFCoords
  
  def self.human_name
    "PFTrack/PFMatchit .2dt file"
  end
  
  def self.distinct_file_ext
    ".2dt"
  end
  
  def self.known_snags
    'PFTrack only exports the trackers for the solved part of the shot. To export the whole shot, ' + 
    "first delete the camera solve."
  end
  
  CHARACTERS_OR_QUOTES = /[AZaz"]/
  INTS = /^\d+$/
  
  def each(&blk)
    until @io.eof?
      line = @io.gets
      next if (!line || line =~ /^#/)
      
      if line =~ CHARACTERS_OR_QUOTES # Tracker with a name
        name = unquote(line.strip)
        report_progress("Reading tracker #{name}")
        parse_trackers(name, @io, &blk)
      end
    end
  end
  
  private
    def parse_trackers(name, io, &blk)
      first_tracker_line = io.gets.chomp
      
      # We will be reading one line too many possibly, so we need to know
      # where to return to in case we do
      first_data_offset = io.pos
      second_tracker_line = io.gets.chomp
      
      # Camera name in version 5 format, might be integer might be string
      if first_tracker_line =~ CHARACTERS_OR_QUOTES || second_tracker_line =~ INTS
        t = Tracksperanto::Tracker.new(:name => name)
        
        # Add cam name to the tracker
        t.name += ("_%s" % unquote(first_tracker_line))
        num_of_keyframes = second_tracker_line.to_i
        extract_tracker(num_of_keyframes, t, io)
        yield(t)
        
        # Now try to extract the second one
        cur_pos = io.pos
        next_line = io.gets
        io.seek(cur_pos)
        return if !next_line || next_line.strip.empty?
        
        parse_trackers(name, io, &blk)
      else
        num_of_keyframes = first_tracker_line.to_i
        # Backtrack to where we were on this IO so that the first line read will be the tracker
        report_progress("Backtracking to the beginning of data block")
        io.seek(first_data_offset)
        
        t = Tracksperanto::Tracker.new(:name => name)
        extract_tracker(num_of_keyframes, t, io)
        yield(t)
      end
      
    end
    
    def extract_tracker(num_of_keyframes, t, io)
      (1..num_of_keyframes).map do | keyframe_idx |
        report_progress("Reading keyframe #{keyframe_idx} of #{num_of_keyframes} in #{t.name}")
        f, x, y, residual = io.gets.chomp.split
        t.keyframe!(:frame => f.to_f - 1, 
          :abs_x => from_pfcoord(x), :abs_y => from_pfcoord(y),
             :residual => residual.to_f * 8)
      end
    end
    
    def unquote(s)
      s.gsub(/"/, '')
    end
end
