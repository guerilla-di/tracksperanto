# -*- encoding : utf-8 -*-
require 'delegate'
require File.expand_path(File.dirname(__FILE__)) + "/nuke_grammar/utils"
require 'tickly'

class Tracksperanto::Import::NukeScript < Tracksperanto::Import::Base
  
  def self.human_name
    "Nuke .nk script file with Tracker, Reconcile3D and PlanarTracker nodes"
  end
  
  def self.distinct_file_ext
    ".nk"
  end
  
  def self.known_snags
    'The only supported nodes that we can extract tracks from are Reconcile3D, PlanarTracker and Tracker (supported Nuke versions are 5, 6 and 7)'
  end
  
  def each
    script_tree = Tickly::Parser.new.parse(@io)
    evaluator = Tickly::Evaluator.new
    evaluator.add_node_handler_class(Tracker3)
    evaluator.add_node_handler_class(Reconcile3D)
    evaluator.add_node_handler_class(PlanarTracker1_0)
    evaluator.add_node_handler_class(Tracker4)
    
    script_tree.each do | node |
      result = evaluator.evaluate(node)
      if result
        result.trackers.each do | t |
          report_progress("Scavenging tracker #{t.name}")
          yield t
        end
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
      u = Tracksperanto::NukeGrammarUtils.new
      point_channel.to_a.map do | curve_argument | 
        if curve_argument[0] == "curve"
          u.parse_curve(curve_argument.to_a)
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
  
  class Tracker4 < Tracker3
    
    def initialize(options)
      
      @name = options["name"]
      @trackers = []
      tracks = options["tracks"]
      preamble = tracks[0]
      headers = tracks[1]
      values = tracks[2]
      
      table_headers = headers[0].map{|header| header[0][-1]}
      #puts table_headers.inspect
      # When this was written, this was the order of the columns in the table:
      # le("e", "name", "track_x", "track_y", "offset_x", "offset_y", "T", "R", "S", "error", 
      #  "error_min", "error_max", "pattern_x", "pattern_y", "pattern_r", "pattern_t", "search_x",
      # "search_y", "search_r", "search_t", "key_track", "key_search_x", "key_search_y", "key_search_r",
      # "key_search_t", "key_track_x", "key_track_y", "key_track_r", "key_track_t", "key_centre_offset_x", "key_centre_offset_y")
      tracker_rows = values[0]
      
      u = Tracksperanto::NukeGrammarUtils.new
      
      tracker_rows.each do | row |
        row_content = row[0][0]
        # For offsets see above
        point_name, x_curve, y_curve = row_content[1], u.parse_curve(row_content[2].to_a), u.parse_curve(row_content[3].to_a)
        
        full_name = [options["name"], point_name].join('_')
        tracker = package_tracker(full_name, x_curve, y_curve)
        @trackers << tracker
      end
    end
  end
end
