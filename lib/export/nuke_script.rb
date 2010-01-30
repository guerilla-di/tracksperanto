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
 format "%d %d 0 0 %d %d 1"
 name CompSize_%dx%d
 postage_stamp false
 xpos 0
 ypos -60
}]  
    SCHEMATIC_OFFSET = 30
    class T < Array
      attr_accessor :name
      include ::Tracksperanto::BlockInit
    end
    
    def self.desc_and_extension
      "nuke.nk"
    end
    
    def self.human_name
      "Nuke .nk script"
    end
    
    def start_export(w, h)
      @io.puts(PREAMBLE % ([w, h] * 3))
      @ypos = 0
    end
    
    # We accumulate a tracker and on end dump it out in one piece
    def start_tracker_segment(tracker_name)
      # Setup for the next tracker
      @tracker = T.new(:name => tracker_name)
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