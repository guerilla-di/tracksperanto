# Implements just_export for quickly pushing trackers out through an exporter without using Pipeline
# plumbing
module Tracksperanto::SimpleExport
  # Acccepts an array of Tracker objects and comp size.
  # Before calling this, initialize the exporter with the proper
  # IO handle
  def just_export(trackers_array, comp_width, comp_height)
    lint = Tracksperanto::Tool::Lint.new(self)
    
    lint.start_export(comp_width, comp_height)
    trackers_array.each do | t |
      lint.start_tracker_segment(t.name)
      t.each do | kf |
        lint.export_point(kf.frame, kf.abs_x, kf.abs_y, kf.residual)
      end
      lint.end_tracker_segment
    end
    lint.end_export
  end
end


