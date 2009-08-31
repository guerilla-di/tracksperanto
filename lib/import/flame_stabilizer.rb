require 'stringio'

class Tracksperanto::Import::FlameStabilizer < Tracksperanto::Import::Base
  # Flame records channels in it's .stabilizer file. Per tracker, we use tracker1/track/x and tracker1/track/y as the base
  # tracking value. Then, the tracker1/shift/x and tracker1/shift/y are added to it. The problem is that when we track backwards
  # the main reference keyframe for the x and y coordinates that sets the base for the animation might be at the last frame, at
  # a frame in the middle or in the end of the setup. We have to pluck it out and then we compute the shift relative to the values
  # in this main frame. Obviously we discard the track width and search width information as we cannot use it in any meaningful way.
  #
  # Here is how the relevant portions look like this (note the tab indents, not spaces, indentation starts at hashmark)
  #Channel tracker1/shift/x
  #	Extrapolation linear
  #	Value 0
  #	Size 185
  #	KeyVersion 1
  #	Key 0
  #		Frame 1
  #		Value 0
  #		Interpolation linear
  #		RightSlope 0.15802
  #		LeftSlope 0.15802
  #		End
  #	Key 1
  #
  # This is in big lines:
  # (tabs)Key(space)Value
  def parse(stabilizer_setup_content)
    trackers = []
    
    io = StringIO.new(stabilizer_setup_content)
    
    trackers
  end
end