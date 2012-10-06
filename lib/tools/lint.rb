# -*- encoding : utf-8 -*-
# Prevents you from exporting invalid trackers
class Tracksperanto::Tool::Lint < Tracksperanto::Tool::Base
  
  def self.action_description
    "Verify all the exported trackers and check for errors"
  end
  
  class NoTrackersExportedError < RuntimeError
    def message
      "There were no trackers exported"
    end
  end
  
  class NonSequentialKeyframes < RuntimeError
    def initialize(args)
      @name, @last_frame, @current_frame = args
    end
    
    def message
      "A keyframe for #{@name} has been sent that comes before the previous keyframe (#{@current_frame} should NOT come after #{@last_frame})."
    end
  end
  
  class EmptyTrackerSentError < RuntimeError
    def initialize(name)
      @name  = name
    end
    
    def message
      "The tracker #{@name} contained no keyframes. Probably there were some filtering ops done and no keyframes have been exported"
    end
  end

  class TrackerRestartedError < RuntimeError
    def initialize(name)
      @name  = name
    end
    
    def message
      "The tracker #{@name} has been sent before the last tracker finished"
    end
  end
  
  def start_export(w, h)
    @trackers = 0
    @keyframes = 0
    @last_tracker_name = nil
    super
  end
  
  def start_tracker_segment(name)
    raise TrackerRestartedError.new(name) if @in_tracker
    
    @in_tracker = true
    @last_tracker_name = name
    @keyframes = 0
    @last_frame = nil
    super
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    @keyframes += 1
    if @last_frame
      raise NonSequentialKeyframes, [@last_tracker_name, @last_frame, frame] if @last_frame > frame
    end
    @last_frame = frame
    
    super
  end
  
  def end_tracker_segment
    raise EmptyTrackerSentError.new(@last_tracker_name) if @keyframes.zero?
    @trackers +=1
    @in_tracker = false
    super
  end
  
  def end_export
    raise NoTrackersExportedError if @trackers.zero?
    super
  end
end
