# Export for Syntheyes tracker UVs. We actually just use prebaked sample values, and do not use bitmasks such as
# OUTCOME_RUN = 1 
# OUTCOME_ENABLE = 2  -- mirrors the enable track 
# OUTCOME_OK = 4   -- usable u/v present on this frame 
# OUTCOME_KEY = 8   -- there is a key here (OK will be on too) 
# OUTCOME_JUMPED = 16 
# OUTCOME_OUTASIGHT = 32 
class Tracksperanto::Export::SynthEyes < Tracksperanto::Export::Base
  include Tracksperanto::UVCoordinates
  
  STATUS_KF = 30
  STATUS_STD = 7
  STATUS_REENABLE = 15
  
  def self.desc_and_extension
    "syntheyes_2dt.txt"
  end
  
  def self.human_name
    "Syntheyes 2D tracker paths file"
  end
  
  def start_export( img_width, img_height)
    @width, @height = img_width, img_height
  end
  
  def start_tracker_segment(tracker_name)
    @last_f, @tracker_name = nil, tracker_name
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    values = [@tracker_name, frame] + absolute_to_uv(abs_float_x, abs_float_y, @width, @height)
    values << get_outcome_code(frame)
    @io.puts("%s %d %.6f %.6f %d" % values)
  end
  
  private
    # It's very important that we provide an outcome code for Syntheyes. Regular keyframes get
    # STATUS_STD, and after a gap we have to signal STATUS_REENABLE, otherwise this might bust solves
    def get_outcome_code(frame)
      outcome = if @last_f.nil?
        STATUS_KF
      elsif @last_f && (@last_f != frame -1)
        STATUS_REENABLE
      else
        STATUS_STD
      end
      @last_f = frame
      outcome
    end
end
