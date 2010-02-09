require File.dirname(__FILE__) + '/../lib/tracksperanto' unless defined?(Tracksperanto)
require 'test/unit'
require 'rubygems'
require 'flexmock'
require 'flexmock/test_unit'

# This module creates ideal parabolic tracks for testing exporters. The two trackers
# will start at opposite corners of the image and traverse two parabolic curves, touching
# the bounds of the image at the and and in the middle. On the middle frame they will vertically
# align. To push the parabolics through your exporter under test, run
#
#   export_parabolics_with(my_exporter)
#
# The tracker residual will degrade linarly and wll be "good" at the first image, "medium" at the extreme
# and "bad" at end
module ParabolicTracks
  x_uv_chain = [
    -1.0, -0.9, -0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1, 0, 
    0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0
  ]
  
  def self.uv_to_abs(uv_x, uv_y, w, h)
    x_wt = w.to_f / 2.0
    y_wt = h.to_f / 2.0
    [(uv_x + 1) * x_wt, ((uv_y) * y_wt) * 2] 
  end
  
  from_uv = lambda do | coordinate, dimension |
    dimension_part = dimension / 2
    (coordinate + 1.0) * dimension_part
  end
  
  tuples_for_tracker_1 = x_uv_chain.inject([]) do | tuples_m, x_value |
    tuples_m << [tuples_m.length, x_value, x_value ** 2]
  end
  
  tuples_for_tracker_2 = tuples_for_tracker_1.map do | tuple |
    [tuple[0], tuple[1], (tuple[2] * -1) + 1]
  end
  
  tuples_for_tracker_2.reverse!
  tuples_for_tracker_2.each_with_index do | t, i |
    t[0] = i
  end
  
  residual_unit = 1.0 / x_uv_chain.length
  
  SKIPS = [10,11]
  FIRST_TRACK = Tracksperanto::Tracker.new(:name => "Parabolic_1_from_top_left") do | t |
    tuples_for_tracker_1.each do | (f, x, y )|
      ax, ay = uv_to_abs(x, y, 1920, 1080)
      unless SKIPS.include?(f)
        t.keyframe!(:frame => f, :abs_x => ax, :abs_y => ay, :residual => (f * residual_unit))
      end
    end
  end
  
  SECOND_TRACK = Tracksperanto::Tracker.new(:name => "Parabolic_2_from_bottom_right") do | t |
    tuples_for_tracker_2.each do | (f, x, y )|
      ax, ay = uv_to_abs(x, y, 1920, 1080)
      unless SKIPS.include?(f)
        t.keyframe!(:frame => f, :abs_x => ax, :abs_y => ay, :residual => (f * residual_unit))
      end
    end
  end
  
  def create_reference_output(exporter_klass, ref_path)
    File.open(ref_path, "w") do | io |
      x = exporter_klass.new(io)
      yield(x) if block_given?
      export_parabolics_with(x)
    end
  end
  
  def ensure_same_output(exporter_klass, reference_path)
    io = StringIO.new
    x = exporter_klass.new(io)
    yield(x) if block_given?
    export_parabolics_with(x)
    io.close
    
    assert_equal File.read(reference_path), io.string
  end
  
  def export_parabolics_with(exporter)
    exporter.start_export(1920, 1080)
    [FIRST_TRACK, SECOND_TRACK].each do | t |
      exporter.start_tracker_segment(t.name)
      t.keyframes.each do | kf |
        exporter.export_point(kf.frame, kf.abs_x, kf.abs_y, kf.residual)
      end
      exporter.end_tracker_segment
    end
    exporter.end_export
  end
end unless defined?(ParabolicTracks)