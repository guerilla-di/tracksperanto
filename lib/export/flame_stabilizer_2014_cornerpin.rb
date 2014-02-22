# -*- encoding : utf-8 -*-
# Exports setups with tracker naming that works with the Action bilinears
class Tracksperanto::Export::FlameStabilizer2014Cornerpin < Tracksperanto::Export::FlameStabilizer2014
  
  def self.desc_and_extension
    "flamesmoke_2014_cornerpin.stabilizer"
  end
  
  def self.human_name
    "Flame/Smoke 2D Stabilizer setup (v. 2014 and above) for corner pins"
  end
  
  # The trackers for cornerpins should go in Z order, but now
  # in N order, unline it did previously. Like so:
  #
  #     TL(1)     TR(3)
  #      ˆ \       ˆ
  #      |  \      |
  #      |    \    |
  #      |      \  |
  #     BL(0)     BR(2)
  #
  # This "kinda tool" ensures that this is indeed taking place
  class Sorter
    include Tracksperanto::SimpleExport # so that it calls OUR methods
    
    def initialize(exporter)
      @exp = exporter
    end
    
    def start_export(w,h)
      @width, @height = w, h
      @corners, @four_done = [], false
    end
    
    def start_tracker_segment(name)
      @four_done = (@corners.length == 4)
      return if @four_done
      @corners.push(Tracksperanto::Tracker.new(:name => name))
    end
    
    def export_point(f, x, y, r)
      return if @four_done
      @corners[-1].keyframe! :frame => f, :abs_x => x, :abs_y => y, :residual => r
    end
    
    def end_tracker_segment
      # Just leave that
    end
    
    def end_export
      # We will have problems sorting if we have too few trackers
      return @exp.just_export(@corners, @width, @height) unless @corners.length == 4
      
      # Sort the trackers, first in Y of the first keyframe
      in_y = sort_on_first_keyframe(@corners, :abs_y)
      
      # then on the X for the two separate blocks for top and bottom
      tl, tr = sort_on_first_keyframe(in_y[2..3], :abs_x)
      bl, br = sort_on_first_keyframe(in_y[0..1], :abs_x)
      
      bulk = [bl, tl, br, tr] # New Flame 2014 order
      
      @exp.just_export(bulk, @width, @height)
    end
    
    private
    
    def sort_on_first_keyframe(enum, property)
      enum.sort{|a, b| a[0].send(property) <=> b[0].send(property) }
    end
  end
  
  # Initialize the exporter with a preconfigured sorter around it.
  # When this object receives the commands they will come from the Sorter instead,
  # and the trackers will already be in their Z-order
  def self.new(*arguments)
    object = super
    Sorter.new(object)
  end
  
  # Now instead of names we got vague indices. YAY for Rue Duc!
  CORNERPIN_NAMING = %w( none tracker0_0 tracker0_1 tracker1_0 tracker1_1 )
  
  # Overridden to give the right names to trackers
  def prefix(tracker_channel)
    tracker_name = CORNERPIN_NAMING[@counter]
    [tracker_name, tracker_channel].join("/")
  end
  
  def start_tracker_segment(tracker_name)
    if (@counter == 4)
      @skip = true
    else
      super
    end 
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    return if @skip
    super
  end
  
  def end_tracker_segment
    return if @skip
    super
  end
end
