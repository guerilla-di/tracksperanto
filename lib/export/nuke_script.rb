# Export each tracker as a single Tracker3 node
class Tracksperanto::Export::NukeScript < Tracksperanto::Export::Base
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
Constant {
 inputs 0
 channels rgb
 format "1920 1080 0 0 1920 1080 1"
 name CompSize_1920x1080
 postage_stamp false
 xpos 0
 ypos -60
}]  
    SCHEMATIC_OFFSET = 30
    class T < Array
      attr_accessor :name
      include ::Tracksperanto::BlockInit
    end
    
    # Should return the suffix and extension of this export file (like "_flame.stabilizer")
    def self.desc_and_extension
      "nuke.nk"
    end
    
    def self.human_name
      "Nuke .nk script"
    end
    
    def start_export(w, h)
      @io.puts(PREAMBLE.gsub(/1920/, w.to_s).gsub(/1080/, h.to_s))
      @ypos = 0
    end
    
    # We accumulate a tracker and on end dump it out in one piece
    def start_tracker_segment(tracker_name)
      # Setup for the next tracker
      @tracker = T.new
      @tracker.name = tracker_name
    end
    
    def end_tracker_segment
      @io.puts( 
        NODE_TEMPLATE % [curves_from_tuples(@tracker), @tracker.name, (@ypos += SCHEMATIC_OFFSET)]
      )
    end
    
    def export_point(frame, abs_float_x, abs_float_y, float_residual)
      # Nuke uses 1-based frames
      @tracker << [frame + 1, abs_float_x, abs_float_y]
    end
    
    private 
    # Generates a couple of Nuke curves (x and y) from the passed tuples of [frame, x, y]
    def curves_from_tuples(tuples)
      x_values, y_values, last_frame_exported = [], [], nil
      tuples.each do | t |
        f = t.shift
        unless last_frame_exported == (f - 1) # new section
          x_values << "x#{f}"
          y_values << "x#{f}"
        end
        t.map!{|e| KEYFRAME_PRECISION_TEMPLATE % e }
        x_values << t.shift
        y_values << t.shift
        last_frame_exported = f
      end
      st = [x_values.join(" "), y_values.join(" ")].map{|e| "{curve i %s}" % e }.join(" ")
    end
end