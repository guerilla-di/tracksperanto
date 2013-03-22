# -*- encoding : utf-8 -*-
require "rubygems"
require File.dirname(__FILE__) + '/../lib/tracksperanto' unless defined?(Tracksperanto)
require 'test/unit'
require 'fileutils'

require 'bundler'
Bundler.require :development

unless File.exist?(File.dirname(__FILE__) + "/import/samples")
  puts "Please run tests on a git checkout from http://github.com/guerilla-di/tracksperanto"
  puts "so that you also have the 17-something megs of the test corpus to test against. Aborting."
  exit 1
end

# http://redmine.ruby-lang.org/issues/4882
# https://github.com/jimweirich/flexmock/issues/4
# https://github.com/julik/flexmock/commit/4acea00677e7b558bd564ec7c7630f0b27d368ca
class FlexMock::PartialMockProxy
  def singleton?(method_name)
    @obj.singleton_methods.include?(method_name.to_s)
  end
end

# This module creates ideal parabolic tracks for testing exporters. The two trackers
# will start at opposite corners of the image and traverse two parabolic curves, touching
# the bounds of the image at the and and in the middle. On the middle frame they will vertically
# align. To push the parabolics through your exporter under test, run
#
#   export_parabolics_with(my_exporter)
#
# The tracker residual will degrade linarly and wll be "good" at the first image, "medium" at the extreme
# and "bad" at end.
#
# The test tracks are precomputed to prevent failing tests due to float rounding biases on different platforms.
# You can see the computation involved in generating these tracks in
# https://github.com/guerilla-di/tracksperanto/commit/371214b47b2ead857c4af17eee1f8d19c62d1dd6#diff-5
module ParabolicTracks
  
  FIRST_TRACK = Tracksperanto::Tracker.new(:name => "Parabolic_1_from_top_left") do |t|
    t.keyframe!(:frame => 0, :abs_x => 0.00000, :abs_y => 1080.00000, :residual => 0.00000)
    t.keyframe!(:frame => 1, :abs_x => 96.00000, :abs_y => 874.80000, :residual => 0.04762)
    t.keyframe!(:frame => 2, :abs_x => 192.00000, :abs_y => 691.20000, :residual => 0.09524)
    t.keyframe!(:frame => 3, :abs_x => 288.00000, :abs_y => 529.20000, :residual => 0.14286)
    t.keyframe!(:frame => 4, :abs_x => 384.00000, :abs_y => 388.80000, :residual => 0.19048)
    t.keyframe!(:frame => 5, :abs_x => 480.00000, :abs_y => 270.00000, :residual => 0.23810)
    t.keyframe!(:frame => 6, :abs_x => 576.00000, :abs_y => 172.80000, :residual => 0.28571)
    t.keyframe!(:frame => 7, :abs_x => 672.00000, :abs_y => 97.20000, :residual => 0.33333)
    t.keyframe!(:frame => 8, :abs_x => 768.00000, :abs_y => 43.20000, :residual => 0.38095)
    t.keyframe!(:frame => 9, :abs_x => 864.00000, :abs_y => 10.80000, :residual => 0.42857)
    t.keyframe!(:frame => 12, :abs_x => 1152.00000, :abs_y => 43.20000, :residual => 0.57143)
    t.keyframe!(:frame => 13, :abs_x => 1248.00000, :abs_y => 97.20000, :residual => 0.61905)
    t.keyframe!(:frame => 14, :abs_x => 1344.00000, :abs_y => 172.80000, :residual => 0.66667)
    t.keyframe!(:frame => 15, :abs_x => 1440.00000, :abs_y => 270.00000, :residual => 0.71429)
    t.keyframe!(:frame => 16, :abs_x => 1536.00000, :abs_y => 388.80000, :residual => 0.76190)
    t.keyframe!(:frame => 17, :abs_x => 1632.00000, :abs_y => 529.20000, :residual => 0.80952)
    t.keyframe!(:frame => 18, :abs_x => 1728.00000, :abs_y => 691.20000, :residual => 0.85714)
    t.keyframe!(:frame => 19, :abs_x => 1824.00000, :abs_y => 874.80000, :residual => 0.90476)
    t.keyframe!(:frame => 20, :abs_x => 1920.00000, :abs_y => 1080.00000, :residual => 0.95238)
  end
  
  SECOND_TRACK = Tracksperanto::Tracker.new(:name => "Parabolic_2_from_bottom_right") do |t|
    t.keyframe!(:frame => 0, :abs_x => 1920.00000, :abs_y => 0.00000, :residual => 0.00000)
    t.keyframe!(:frame => 1, :abs_x => 1824.00000, :abs_y => 205.20000, :residual => 0.04762)
    t.keyframe!(:frame => 2, :abs_x => 1728.00000, :abs_y => 388.80000, :residual => 0.09524)
    t.keyframe!(:frame => 3, :abs_x => 1632.00000, :abs_y => 550.80000, :residual => 0.14286)
    t.keyframe!(:frame => 4, :abs_x => 1536.00000, :abs_y => 691.20000, :residual => 0.19048)
    t.keyframe!(:frame => 5, :abs_x => 1440.00000, :abs_y => 810.00000, :residual => 0.23810)
    t.keyframe!(:frame => 6, :abs_x => 1344.00000, :abs_y => 907.20000, :residual => 0.28571)
    t.keyframe!(:frame => 7, :abs_x => 1248.00000, :abs_y => 982.80000, :residual => 0.33333)
    t.keyframe!(:frame => 8, :abs_x => 1152.00000, :abs_y => 1036.80000, :residual => 0.38095)
    t.keyframe!(:frame => 9, :abs_x => 1056.00000, :abs_y => 1069.20000, :residual => 0.42857)
    t.keyframe!(:frame => 12, :abs_x => 768.00000, :abs_y => 1036.80000, :residual => 0.57143)
    t.keyframe!(:frame => 13, :abs_x => 672.00000, :abs_y => 982.80000, :residual => 0.61905)
    t.keyframe!(:frame => 14, :abs_x => 576.00000, :abs_y => 907.20000, :residual => 0.66667)
    t.keyframe!(:frame => 15, :abs_x => 480.00000, :abs_y => 810.00000, :residual => 0.71429)
    t.keyframe!(:frame => 16, :abs_x => 384.00000, :abs_y => 691.20000, :residual => 0.76190)
    t.keyframe!(:frame => 17, :abs_x => 288.00000, :abs_y => 550.80000, :residual => 0.80952)
    t.keyframe!(:frame => 18, :abs_x => 192.00000, :abs_y => 388.80000, :residual => 0.85714)
    t.keyframe!(:frame => 19, :abs_x => 96.00000, :abs_y => 205.20000, :residual => 0.90476)
    t.keyframe!(:frame => 20, :abs_x => 0.00000, :abs_y => 0.00000, :residual => 0.95238)
  end
  
  SINGLE_FRAME_TRACK = Tracksperanto::Tracker.new(:name => "SingleFrame_InTheMiddle") do |t|
    t.keyframe!(:frame => 0, :abs_x => 970.00000, :abs_y => 550.00000, :residual => 0.00000)
  end
  
  def create_reference_output(exporter_klass, ref_path)
    File.open(ref_path, "w") do | io |
      x = exporter_klass.new(io)
      yield(x) if block_given?
      export_parabolics_with(x)
    end
    flunk "The test output was overwritten, so this test is meaningless"
  end
  
  def assert_same_buffer(ref_buffer, actual_buffer, message = "The line should be identical")
    [ref_buffer, actual_buffer].each{|io| io.rewind }
    
    # There are subtle differences in how IO is handled on dfferent platforms (Darwin)
    lineno = 0
    begin
      loop do
        return if ref_buffer.eof? && actual_buffer.eof?
        lineno += 1
        ref_line, actual_line = ref_buffer.readline, actual_buffer.readline
        assert_equal ref_line, actual_line, "Mismatch on line #{lineno}:"
      end
    rescue EOFError
      flunk "One of the buffers was too short at #{lineno}"
    end
  end
  
  def ensure_same_output(exporter_klass, reference_path, message = "The line should be identical")
    # If we need to update ALL the references at once
    if ENV['TRACKSPERANTO_OVERWRITE_ALL_TEST_DATA']
      STDERR.puts "Achtung! Overwriting the file at #{reference_path} with the test output for now"
      create_reference_output(exporter_klass, reference_path) do | x |
        yield(x) if block_given?
      end
      return
    end
    
    io = StringIO.new
    x = exporter_klass.new(io)
    yield(x) if block_given?
    export_parabolics_with(x)
    
    assert_same_buffer(File.open(reference_path, "r"), io, message)
  end
  
  def export_parabolics_with(exporter)
    exporter.start_export(1920, 1080)
    [FIRST_TRACK, SECOND_TRACK, SINGLE_FRAME_TRACK].each do | t |
      exporter.start_tracker_segment(t.name)
      t.keyframes.each do | kf |
        exporter.export_point(kf.frame, kf.abs_x, kf.abs_y, kf.residual)
      end
      exporter.end_tracker_segment
    end
    exporter.end_export
  end
end unless defined?(ParabolicTracks)
