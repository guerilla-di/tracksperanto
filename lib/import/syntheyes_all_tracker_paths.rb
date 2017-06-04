class Tracksperanto::Import::SyntheyesAllTrackerPaths < Tracksperanto::Import::Base
  def self.human_name
    "Syntheyes \"All Tracker Paths\" export .txt file"
  end
  
  CHARACTERS_OR_QUOTES = /[AZaz"]/
  TRACKER_KEYFRAME = /^(\d+) ((\d+)\.(\d+)) ((\d+)\.(\d+))/
  
  def self.known_snags
    "Syntheyes has two formats for exporting tracks. One is called \"Tracker 2-D paths\" in the menu. " +
    "The other is called \"All Tracker Paths\". You told Tracksperanto to treat your file as " +
    "\"All Tracker Paths\", if something goes wrong might be a good idea to try the other Tracksperanto input format"
  end
  
  
  def each
    t = Tracksperanto::Tracker.new
    while line = @io.gets do
      if line =~ CHARACTERS_OR_QUOTES
        t = Tracksperanto::Tracker.new(:name => line)
        fill_tracker(t, @io)
        yield(t)
      end
    end
  end
  
  private
  
  def fill_tracker(t, io)
    loop do
      prev_pos = io.pos
      line = io.gets
      if line =~ TRACKER_KEYFRAME
        parts = line.scan(TRACKER_KEYFRAME).flatten
        t.keyframe!(:frame => parts[0], :abs_x => parts[1], :abs_y => parts[2])
      else
        # Backtrack to where we started the line and return control
        io.pos = prev_pos
        return
      end
    end
  end
  
end
