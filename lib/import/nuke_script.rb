# -*- encoding : utf-8 -*-
require 'delegate'
require File.expand_path(File.dirname(__FILE__)) + "/nuke_grammar/utils"

class Tracksperanto::Import::NukeScript < Tracksperanto::Import::Base
  
  def self.human_name
    "Nuke .nk script file with Tracker, Reconcile3D and PlanarTracker nodes"
  end
  
  def self.distinct_file_ext
    ".nk"
  end
  
  def each
    io = Tracksperanto::ExtIO.new(@io)
    while line = io.gets_and_strip
      if line =~ TRACKER_3_PATTERN
        scan_tracker_node(io).each(&Proc.new)
      elsif line =~ RECONCILE_PATTERN
        scan_reconcile_node(io).each(&Proc.new)
      elsif line =~ PLANAR_PATTERN
        scan_planar_tracker_node(io).each(&Proc.new)
      end
    end
  end
  
  private
    
    TRACKER_3_PATTERN = /^Tracker3 \{/
    RECONCILE_PATTERN = /^Reconcile3D \{/
    PLANAR_PATTERN = /^PlanarTracker1_0 \{/
    OUTPUT_PATTERN = /^output \{/
    TRACK_PATTERN = /^track(\d) \{/
    NODENAME = /^name ([^\n]+)/
    PLANAR_CORNERS = %w( outputBottomLeft outputBottomRight outputTopLeft outputTopRight)
    
    # Scans a Reconcile3D node and returs it's output
    def scan_reconcile_node(io)
      t = Tracksperanto::Tracker.new
      while line = io.gets_and_strip
        if line =~ OUTPUT_PATTERN
          t = extract_tracker(line)
        elsif line =~ NODENAME
          t.name = "Reconcile_#{$1}"
          report_progress("Scavenging Reconcile3D node #{t.name}")
          return [t] # Klunky
        end
      end
    end
    
    # Scans a PlanarTracker node and recovers corner pin
    def scan_planar_tracker_node(io)
      trackers, node_name = [], nil
      while line = io.gets_and_strip
        PLANAR_CORNERS.each do | corner_name |
          if line =~ /#{corner_name}/
            t = Tracksperanto::Tracker.new
            t = extract_tracker(line)
            t.name = corner_name
            trackers.push(t.dup)
          elsif line =~ NODENAME
            node_name = $1
          end
        end
        
        if node_name && trackers.length == 4
          trackers.each{|t| t.name = "%s_%s" % [node_name, t.name] }
          return trackers
        end
      end
      
      # Fail
      return []
    end
    
    # Scans a tracker node and return all tracks within that node (no more than 4)
    def scan_tracker_node(io)
      tracks_in_tracker = []
      while line = io.gets_and_strip
        if line =~ TRACK_PATTERN
          t = extract_tracker(line)
          tracks_in_tracker.push(t) if t
        elsif line =~ NODENAME
          tracks_in_tracker.each_with_index do | t, i |
            t.name = "#{$1}_track#{i+1}"
            report_progress("Scavenging Tracker3 node #{t.name}")
          end
          return tracks_in_tracker
        end
      end
      raise "Tracker node went all the way to end of stream"
    end
    
    def scan_track(line_with_curve)
      x_curve, y_curve = line_with_curve.split(/\}/).map do | one_curve| 
        Tracksperanto::NukeGrammarUtils.new.parse_curve(one_curve)
      end
      return nil unless (x_curve && y_curve)
      zip_curve_tuples(x_curve, y_curve)
    end
    
    def extract_tracker(line)
      tuples = scan_track(line)
      return nil unless (tuples && tuples.any?)
      Tracksperanto::Tracker.new do | t |
        tuples.each do | (f, x, y) |
            t.keyframe!(:frame => (f -1), :abs_x => x, :abs_y => y) 
        end
      end
    end
end
