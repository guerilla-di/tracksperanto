require File.dirname(__FILE__) + '/helper'

class FlameImportTest < Test::Unit::TestCase
  DELTA = 0.1 
  BLOCK_WITH_NO_KF = %{Channel tracker1/ref/width
    	Extrapolation constant
    	Value 10
    	Colour 50 50 50 
    	End
  }
  BLOCK_WITH_KEYFRAMES = %{
    Channel tracker1/ref/dx
    Extrapolation constant
    Value 0
    Size 5
    KeyVersion 1
    Key 0
    	Frame 0
    	Value 0
    	ValueLock yes
    	DeleteLock yes
    	Interpolation constant
    	End
    Key 1
    	Frame 1
    	Value 0
    	Interpolation constant
    	RightSlope -1.9947
    	LeftSlope -1.9947
    	End
    Key 2
    	Frame 44
    	Value -87.7668
    	FrameLock yes
    	Interpolation constant
    	RightSlope -2.31503
    	LeftSlope -2.31503
    	End
    Key 3
    	Frame 74
    	Value -168.997
    	FrameLock yes
    	Interpolation constant
    	RightSlope -2.24203
    	LeftSlope -2.24203
    	End
    Key 4
    	Frame 115
    	Value -246.951
    	FrameLock yes
    	Interpolation constant
    	End
    Colour 50 50 50 
    End
  }

  def test_channel_block_for_channel_without_keyframes
    io = StringIO.new(BLOCK_WITH_NO_KF)
    first_line = io.gets
    name = "foo/bar"
    c = Tracksperanto::Import::FlameStabilizer::ChannelBlock.new(io, name)
    
    assert_equal 1, c.length
    assert_in_delta 10.0, c[0].value, DELTA
    assert_equal 1, c[0].frame
  end
  
  def test_channel_block_for_channel_with_5_keyframes
    io = StringIO.new(BLOCK_WITH_KEYFRAMES)
    first_line = io.gets
    name = "foo/bar"
    c = Tracksperanto::Import::FlameStabilizer::ChannelBlock.new(io, name)
    
    assert_equal 5, c.length
    
    first_key = c[0]
    assert_in_delta 0.0, first_key.value, DELTA
    assert_equal 0, first_key.frame
    
    key_four = c[4]
    assert_not_nil key_four, "The last keyframe should not be nil"
    
    assert_in_delta -246.951, key_four.value, DELTA
    assert_equal 115, key_four.frame
  end
  
  def test_parsing_from_flame
    fixture = File.read(File.dirname(__FILE__) + '/samples/hugeFlameSetup.stabilizer')
    
    parser = Tracksperanto::Import::FlameStabilizer.new
    
    trackers = parser.parse(fixture)
    assert_equal 2048, parser.width
    assert_equal 1176, parser.height
    
    parser.height = 1080
    
    assert_equal 28, trackers.length
    
    first_t = trackers[0]
    assert_equal 546, first_t.keyframes.length
    
    first_k = first_t.keyframes[1]
    
    assert_equal 2, first_k.frame
    assert_in_delta 1022.82062, first_k.abs_x, DELTA
    assert_in_delta 586.82, first_k.abs_y, DELTA
  end
end