# Export each tracker as a single Tracker3 node
class Tracksperanto::Export::NukeScript < Tracksperanto::Export::Base
    
    #:nodoc
    
    NODE_TEMPLATE = %[
Tracker3 {
     track1 {%s}
     name %s
     xpos 0
     ypos %d
}
]
    KEYFRAME_PRECISION_TEMPLATE = "%.4f"
    PREAMBLE = %[
version 5.1200
Root {
 inputs 0
 frame 1
 last_frame %d
}
Constant {
 inputs 0
 channels rgb
 format "%d %d 0 0 %d %d 1"
 name CompSize_%dx%d
 postage_stamp false
 xpos 0
 ypos -60
}]  
    #:doc
    
    # Offset by which the new nodes will be shifted down in the node graph
    SCHEMATIC_OFFSET = 30
    
    def self.desc_and_extension
      "nuke.nk"
    end
    
    def self.human_name
      "Nuke .nk script"
    end
    
    def start_export(w, h)
      @max_frame, @ypos, @w, @h = 0, 0, w, h
      # At the start of the file we need to provide the length of the script.
      # We allocate an IO for the file being output that will contain all the trackers,
      # and then write that one into the script preceded by the preamble that sets length
      # based on the last frame position in time
      @trackers_io = Tracksperanto::BufferIO.new
    end
    
    # We accumulate a tracker and on end dump it out in one piece
    def start_tracker_segment(tracker_name)
      # Setup for the next tracker
      @tracker = Tracksperanto::Tracker.new(:name => tracker_name)
    end
    
    def end_tracker_segment
      coord_tuples = @tracker.map{|kf| [kf.frame, kf.abs_x, kf.abs_y]}
      @trackers_io.puts(
        NODE_TEMPLATE % [curves_from_tuples(coord_tuples), @tracker.name, (@ypos += SCHEMATIC_OFFSET)]
      )
    end
    
    def export_point(frame, abs_float_x, abs_float_y, float_residual)
      # Nuke uses 1-based frames
      @tracker.keyframe!(:frame => frame + 1, :abs_x => abs_float_x, :abs_y => abs_float_y)
      @max_frame = frame if frame > @max_frame
    end
    
    def end_export
      @trackers_io.rewind
      preamble_values = [@max_frame + 1, @w, @h, @w, @h, @w, @h]
      @io.puts(PREAMBLE % preamble_values)
      @io.write(@trackers_io.read) until @trackers_io.eof?
      @trackers_io.close!
    end
    
    private
    
    # Generates a couple of Nuke curves (x and y) from the passed tuples of [frame, x, y]
    def curves_from_tuples(tuples)
      x_values, y_values, last_frame_exported, repeat_jump = [], [], nil, false
      tuples.each do | t |
        f = t.shift
        
        if last_frame_exported != (f - 1) # new section
          x_values << "x#{f}"
          y_values << "x#{f}"
          repeat_jump = true
        elsif repeat_jump
          # If we are AFTER a gap inject another "jump" signal
          # so that Nuke does not animate with gaps but with frames
          x_values << "x#{f}"
          y_values << "x#{f}"
          repeat_jump = false
        end
        
        t.map!{|e| KEYFRAME_PRECISION_TEMPLATE % e }
        x_values << t.shift
        y_values << t.shift
        last_frame_exported = f
      end
      st = [x_values.join(" "), y_values.join(" ")].map{|e| "{curve i %s}" % e }.join(" ")
    end
end