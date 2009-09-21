# The base middleware class works just like a Tracksperanto::Export::Base, but it only wraps another exporting object and does not get registered on it's own
# as an export format. Middleware can be used to massage the tracks being exported in various interesting ways - like moving the coordinates, clipping the keyframes,
# scaling the whole export or even reversing the trackers to go backwards
class Tracksperanto::Middleware::Base
  include Tracksperanto::Casts
  include Tracksperanto::BlockInit
  
  # Used to automatically register your middleware in Tracksperanto.middlewares
  # Normally you wouldn't need to override this
  def self.inherited(by)
    Tracksperanto.middlewares << by
    super
  end
  
  # Constructor accepts the exporter that will be wrapped
  def initialize(exporter, *args_for_block_init)
    @exporter = exporter
    super(*args_for_block_init)
  end
  
  # Called on export start
  def start_export( img_width, img_height)
    @exporter.start_export(img_width, img_height)
  end
  
  # Called on export end
  def end_export
    @exporter.end_export
  end
  
  # Called on tracker start, one for each tracker. Start of the next tracker
  # signifies that the previous tracker has passed by
  def start_tracker_segment(tracker_name)
    @exporter.start_tracker_segment(tracker_name)
  end
  
  # Called on tracker end
  def end_tracker_segment
    @exporter.end_tracker_segment
  end
  
  # Called for each tracker keyframe
  def export_point(at_frame_i, abs_float_x, abs_float_y, float_residual)
    @exporter.export_point(at_frame_i, abs_float_x, abs_float_y, float_residual)
  end
end