# -*- encoding : utf-8 -*-
require 'delegate'
require File.expand_path(File.dirname(__FILE__)) + "/nuke_grammar/utils"

class Tracksperanto::Import::NukeScript < Tracksperanto::Import::Base
  
  def self.human_name
    "Nuke .nk script file"
  end
  
  def self.distinct_file_ext
    ".nk"
  end
  
  def each
    io = Tracksperanto::ExtIO.new(@io)
    while line = io.gets_and_strip
      if line =~ TRACKER_3_PATTERN
        scan_tracker_node(io).each { |t| yield(t) }
      end
    end
  end
  
  private
    
    TRACKER_3_PATTERN = /^Tracker3 \{/
    TRACK_PATTERN = /^track(\d) \{/
    NODENAME = /^name ([^\n]+)/
    
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
