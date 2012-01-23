# -*- encoding : utf-8 -*-
# Export for Syntheyes tracker UVs.
class Tracksperanto::Export::SynthEyes < Tracksperanto::Export::Base
  include Tracksperanto::UVCoordinates
  
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
    @last_registered_frame, @tracker_name = nil, camelize(tracker_name)
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    values = [
        @tracker_name,  frame, convert_to_uv(abs_float_x, @width), 
        convert_to_uv(abs_float_y, @height) * -1, 
        get_outcome_code(frame)
    ]
    @io.puts("%s %d %.6f %.6f %d" % values)
  end
  
  private
    STATUS_KF = 30 # When tracker starts or reenables
    STATUS_STD = 7 # For a standard frame (not a keyframe)
    STATUS_REENABLE = 15 # When the tracker goes back into view
    
    # It's very important that we provide an outcome code for Syntheyes. Regular keyframes get
    # STATUS_STD, and after a gap we have to signal STATUS_REENABLE, otherwise this might bust solves.
    # When syntheyes reads the file, it ORs the status of the keyframe with a number of masks
    # OUTCOME_RUN = 1 
    # OUTCOME_ENABLE = 2  -- mirrors the enable track 
    # OUTCOME_OK = 4   -- usable u/v present on this frame 
    # OUTCOME_KEY = 8   -- there is a key here (OK will be on too) 
    # OUTCOME_JUMPED = 16 
    # OUTCOME_OUTASIGHT = 32 
    # We actually provide pregenerated status codes instead of that to get the desired outcome codes.
    # When you set all frames to be keyframes this affects the solver in a negative way because Syntheyes
    # (reasonably) gives priority to keyframes over standard frames of the tracker - and also
    # the transition frames parameter does not work too well over keyframes
    def get_outcome_code(frame)
      outcome = if @last_registered_frame.nil? || (@last_registered_frame != (frame - 1))
        STATUS_REENABLE
      else
        STATUS_STD
      end
      @last_registered_frame = frame
      outcome
    end

    # The import script in Syntheyes is designed to transform "Tracker_1"
    # into "Tracker 1" by replacing underscores with spaces. This is all good and
    # well but downstream when Syntheyes exports the matchmove some apps will be
    # getting the features reinstated with spaces in their names. In some cases
    # (for example in Maya) this leads to dangling groups because primitives with spaces
    # in names cannot even be created! The reach of this problem is dependent on the
    # sanity of the one who wrote the export sizzle script for Syntheyes. The morale of the
    # story is - we will use CamelCase instead of underscores and avoid having
    # spaces in feature names as such
    def camelize(lower_case_and_underscored_word)
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
end
