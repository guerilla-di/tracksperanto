class Tracksperanto::Import::Boujou < Tracksperanto::Import::Base
  
  def self.human_name
    "Boujou feature tracks export"
  end
  
  def parse(io)
    wrapped_io = Tracksperanto::ExtIO.new(io)
    detect_columns(wrapped_io)
    trackers = {}
    extract_trackers(wrapped_io) do | k |
      name, frame, x, y = k["track_id"], k["view"], k["x"], k["y"]
      trackers[name] ||= Tracksperanto::Tracker.new(:name => name)
      report_progress("Extracting frame #{frame} of #{name}")
      trackers[name].keyframe!(:frame => (frame.to_i - 1), :abs_y => (@height.to_f - y.to_f), :abs_x => x)
    end
    trackers.values.sort{|a,b| a.name <=> b.name }
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
  def extract_trackers(io)
    until io.eof?
      line = io.gets_and_strip
      next if comment?(line)
      yield(make_column_hash(line))
    end
  end
  
  def make_column_hash(line)
    Hash[*@columns.zip(line.split).flatten]
  end
  
  def comment?(line)
    line =~ COMMENT
  end
end