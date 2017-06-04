class Tracksperanto::Import::Boujou < Tracksperanto::Import::Base
  
  def self.human_name
    "Boujou feature tracks export"
  end
  
  def each
    wrapped_io = Tracksperanto::ExtIO.new(@io)
    detect_columns(wrapped_io)
    trackers = {}
    filtering_trackers_from(wrapped_io) do | name, frame, x, y |
      if @last_tracker && (name != @last_tracker.name)
        yield(@last_tracker) if @last_tracker && @last_tracker.any?
        @last_tracker = nil
      end
      
      if !@last_tracker
        @last_tracker = Tracksperanto::Tracker.new(:name => name)
      end
      
      report_progress("Extracting frame #{frame} of #{name}")
      @last_tracker.keyframe!(:frame => (frame.to_i - 1), :abs_y => (@height.to_f - y.to_f - 1), :abs_x => x)
    end
    
    yield(@last_tracker) if @last_tracker && @last_tracker.any?
  end
  
  private
  
  COMMENT = /^# /
  
  def detect_columns(io)
    until io.eof? do 
      line = io.gets_and_strip
      if line =~ /^# track_id/
        report_progress("Detecting columns")
        return set_columns_from(line)
      end
    end
  end
  
  def set_columns_from(line)
    @columns = line.gsub(COMMENT, '').split
  end
  
  #
  #
  # # track_id    view      x    y
  # Target_track_1  5  252.046  171.677
  def filtering_trackers_from(io) #:yields: track_id, frame, x, y
    until io.eof?
      line = io.gets_and_strip
      next if comment?(line)
      column = make_column_hash(line)
      yield(column["track_id"], column["view"], column["x"], column["y"])
    end
  end
  
  def make_column_hash(line)
    Hash[*@columns.zip(line.split).flatten]
  end
  
  def comment?(line)
    line =~ COMMENT
  end
end
