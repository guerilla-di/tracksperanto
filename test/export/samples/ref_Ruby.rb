require 'rubygems'
require 'tracksperanto'
width = 1920
height = 1080
trackers = []
 
trackers << Tracksperanto::Tracker.new(:name => "Parabolic_1_from_top_left") do |t|
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
 
trackers << Tracksperanto::Tracker.new(:name => "Parabolic_2_from_bottom_right") do |t|
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
 
trackers << Tracksperanto::Tracker.new(:name => "SingleFrame") do |t|
  t.keyframe!(:frame => 0, :abs_x => 970.00000, :abs_y => 550.00000, :residual => 0.00000)
end
 
