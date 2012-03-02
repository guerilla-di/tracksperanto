# -*- encoding : utf-8 -*-
class Tracksperanto::Import::SyntheyesAllTrackerPaths < Tracksperanto::Import::Base
  def self.human_name
    "Syntheyes \"All Tracker Paths\" export .txt file"
  end
  
  CHARACTERS_OR_QUOTES = /[AZaz"]/
  TRACKER_KEYFRAME = /^(\d+) ((\d+)\.(\d+)) ((\d+)\.(\d+))/
  
  def each
    until @io.eof?
      line = @io.gets
      if line =~ TRACKER_KEYFRAME
        parts = line.scan(TRACKER_KEYFRAME).flatten
        @last_tracker.keyframe!(:frame => parts[0], :abs_x => parts[1], :abs_y => parts[4])
      elsif line =~ CHARACTERS_OR_QUOTES
        yield(@last_tracker.dup) if @last_tracker
        @last_tracker = Tracksperanto::Tracker.new(:name => line)
        report_progress("Reading tracker #{line.strip}")
      end
      
      # Last tracker
      yield @last_tracker.dup if @last_tracker && @last_tracker.any?
    end
  end
    
end
