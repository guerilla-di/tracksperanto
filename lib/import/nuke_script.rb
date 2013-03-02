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
    'The only supported nodes that we can extract tracks from are Reconcile3D, PlanarTracker and Tracker'
  end
  
  def each
    script_tree = Tickly::Parser.new.parse(@io)
    evaluator = Tickly::Evaluator.new
    evaluator.add_node_handler_class(Tracker3)
    evaluator.add_node_handler_class(Reconcile3D)
    evaluator.add_node_handler_class(PlanarTracker1_0)
    
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
        frame_x_and_y = zip_curve_tuples(curves[0], curves[1])
        tracker = Tracksperanto::Tracker.new(:name => full_name) do | t |
          frame_x_and_y.each do | (f, x, y) |
              t.keyframe!(:frame => (f -1), :abs_x => x, :abs_y => y) 
          end
        end
        
        @trackers << tracker
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
  
  private
    
    def scan_track(line_with_curve)
      x_curve, y_curve = line_with_curve.split(/\}/).map do | one_curve| 
        Tracksperanto::NukeGrammarUtils.new.parse_curve(one_curve)
      end
      return nil unless (x_curve && y_curve)
      zip_curve_tuples(x_curve, y_curve)
    end
    
end
