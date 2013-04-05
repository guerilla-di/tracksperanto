# -*- encoding : utf-8 -*-

require 'tickly'

class Tracksperanto::Import::NukeScript < Tracksperanto::Import::Base
  
  def self.human_name
    "Nuke .nk script file with Tracker, Reconcile3D, PlanarTracker and CornerPin nodes"
  end
  
  def self.distinct_file_ext
    ".nk"
  end
  
  def self.known_snags
    'The only supported nodes that we can extract tracks from are Reconcile3D, PlanarTracker and Tracker (supported Nuke versions are 5, 6 and 7)'
  end
  
  def each
    parser = Tickly::NodeProcessor.new
    parser.add_node_handler_class(Tracker3)
    parser.add_node_handler_class(Reconcile3D)
    parser.add_node_handler_class(PlanarTracker1_0)
    parser.add_node_handler_class(Tracker4)
    parser.add_node_handler_class(CornerPin2D)
    
    parser.parse(@io) do | node |
      node.trackers.each do | t |
        report_progress("Scavenging tracker #{t.name}")
        yield t
      end
    end
  end
  
  private
  
  class Tracker3
    include Tracksperanto::ZipTuples
    attr_reader :trackers

    def initialize(options)
      @trackers = []
      point_channels.each do | point_name |
        next unless options[point_name]
        point_channel = options[point_name]
        
        curves = extract_curves_from_channel(point_channel)
        
        # We must always have 2 anim curves
        next unless curves.length == 2
        
        full_name = [options["name"], point_name].join('_')
        tracker = package_tracker(full_name, curves[0], curves[1])
        
        @trackers << tracker
      end
    end
    
    def package_tracker(full_name, xcurve, ycurve)
      frame_x_and_y = zip_curve_tuples(xcurve, ycurve)
      Tracksperanto::Tracker.new(:name => full_name) do | t |
        frame_x_and_y.each do | (f, x, y) |
            t.keyframe!(:frame => (f -1), :abs_x => x, :abs_y => y) 
        end
      end
    end
    
    def extract_curves_from_channel(point_channel)
      # First element is the :c curly identifier
      point_channel[1..-1].map do | curve_argument | 
        if curve_argument[1] == "curve"
          Tickly::Curve.new(curve_argument)
        else
          nil
        end
      end.compact
    end
    
    def point_channels
      %w( track1 track2 track3 track4 )
    end
    
  end
  
  class Reconcile3D < Tracker3
    def point_channels
      %w( output)
    end
  end
  
  class PlanarTracker1_0 < Tracker3
    def point_channels
      %w( outputBottomLeft outputBottomRight outputTopLeft outputTopRight)
    end
  end
  
  class CornerPin2D < Tracker3
    def point_channels
      %w( to1 to2 to3 to4 )
    end
  end
  
  class Tracker4 < Tracker3
    
    def initialize(options)
      
      @name = options["name"]
      @trackers = []
      tracks = options["tracks"]
      preamble = tracks[1]
      headers = tracks[2]
      values = tracks[3]
      
      # When this was written, this was the order of the columns in the table:
      # le("e", "name", "track_x", "track_y", "offset_x", "offset_y", "T", "R", "S", "error", 
      #  "error_min", "error_max", "pattern_x", "pattern_y", "pattern_r", "pattern_t", "search_x",
      # "search_y", "search_r", "search_t", "key_track", "key_search_x", "key_search_y", "key_search_r",
      # "key_search_t", "key_track_x", "key_track_y", "key_track_r", "key_track_t", "key_centre_offset_x", "key_centre_offset_y")
      tracker_rows = values[0]
      
      # The 0 element is the :c symbol
      tracker_rows[1..-1].each do | row |
        row_content = row[0]
        
        # For offsets see above
        point_name = row_content[2]
        x_curve = Tickly::Curve.new(row_content[3])
        y_curve = Tickly::Curve.new(row_content[4])
        
        full_name = [options["name"], point_name].join('_')
        tracker = package_tracker(full_name, x_curve, y_curve)
        @trackers << tracker
      end
    end
  end
end
