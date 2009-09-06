require 'stringio'

class Tracksperanto::Import::FlameStabilizer < Tracksperanto::Import::Base
  
  class Kf
    include ::Tracksperanto::Casts
    include ::Tracksperanto::BlockInit
    cast_to_int :frame
    cast_to_float :value
  end
  
  T = ::Tracksperanto::Tracker
  K = ::Tracksperanto::Keyframe
  
  class ChannelBlock < Array
    
    attr_accessor :name
    def <=>(o)
      @name <=> o.name
    end
    
    def initialize(io, channel_name)
      @name = channel_name.strip
      
      base_value_matcher = /Value ([\d\.]+)/
      keyframe_count_matcher = /Size (\d+)/
      indent = nil
      
      keyframes = []
      
      while line = io.gets
        indent ||= line.scan(/^(\s+)/)[1]
        
        if line =~ keyframe_count_matcher
          # Remove the keyframes which are already there
          clear
          $1.to_i.times { push(extract_key_from(io)) }
        elsif line =~ base_value_matcher && empty?
          push(Kf.new(:frame => 1, :value => $1))
        elsif line.strip == "#{indent}End"
          break
        end
      end
      
      raise "Parsed a channel #{@name} with no keyframes" if length.zero?
    end
    
    def extract_key_from(io)
      frame = nil
      frame_matcher = /Frame (\d+)/
      value_matcher = /Value ([\-\d\.]+)/
      
      until io.eof?
        line = io.gets
        if line =~ frame_matcher
          frame = $1.to_i
        elsif line =~ value_matcher
          value = $1.to_f
          return Kf.new(:frame => frame, :value => value)
        end
      end
      
      raise "Did not detect any keyframes!"
    end
  end
  
  def parse(stabilizer_setup_content)
    
    io = StringIO.new(stabilizer_setup_content)
    
    self.width, self.height = extract_width_and_height_from_stream(io)
    channels = extract_channels_from_stream(io)
    
    raise "The setup contained no channels that we could process" if channels.empty?
    raise "A channel was nil" if channels.find{|e| e.nil? }
    
    trackers = scavenge_trackers_from_channels(channels)
  end
  
  private
    def extract_width_and_height_from_stream(io)
      w, h = nil, nil
      
      w_matcher = /FrameWidth (\d+)/
      h_matcher = /FrameHeight (\d+)/
      
      until io.eof?
        line = io.gets
        if line =~ w_matcher
          w = $1
        elsif line =~ h_matcher
          h = $1
        end
        
        return [w, h] if (w && h)
      end
      
    end
=begin
  Here's how a Flame channel looks like
The Size will not be present if there are no keyframes
  
Channel tracker1/ref/x
	Extrapolation constant
	Value 770.41
	Size 4
	KeyVersion 1
	Key 0
		Frame 1
		Value 770.41
		Interpolation constant
		End
	Key 1
		Frame 44
		Value 858.177
		Interpolation constant
		RightSlope 2.31503
		LeftSlope 2.31503
		End
	Key 2
		Frame 74
		Value 939.407
		Interpolation constant
		RightSlope 2.24201
		LeftSlope 2.24201
		End
	Key 3
		Frame 115
		Value 1017.36
		Interpolation constant
		End
	Colour 50 50 50 
	End
=end
    
    def extract_channels_from_stream(io)
      channels = []
      channel_matcher = /Channel (.+)\n/
      until io.eof?
        line = io.gets
        if line =~ channel_matcher
          channels << extract_channel_from(io, $1)
        end
      end
      channels
    end
    
    def extract_channel_from(io, channel_name)
      ChannelBlock.new(io, channel_name)
    end
    
    def report_progress(msg)
    end
    
    def scavenge_trackers_from_channels(channels)
      trackers = []
      channels.select{|e| e.name =~ /\/track\/x/}.each do | track_x |
        trackers << grab_tracker(channels, track_x)
      end
      
      trackers
    end
    
    def grab_tracker(channels, track_x)
      t_name = track_x.name.split('/').shift
      t = T.new(:name => t_name)
      matching_y_name = "#{t_name}/track/y"
    
      track_y = channels.find{|e| e.name == matching_y_name }
      raise "Cannot find matching channel #{matching_y_name}" unless track_y
    
      # Find the base keyframe which we will use to compute the shift.
      # Flame adds shift to the value at this keyframe. Since we cannot
      # guarantee that both Y and X keyframes are present we will search
      # the whole channels for a place where it has values both in X and Y
      base_kf = track_x.map do |e| 
        matching_y = track_y.find{|ye| ye.frame == e.frame } 
        unless matching_y
          nil
        else
          [e.frame, e.value, matching_y.value]
        end
      end.compact.shift
    
      raise "No base keyframe found in the track/x and track/y channels" unless base_kf
    
      # Now scan the shift channels
      shift_x = channels.find{|e| e.name == "#{t_name}/shift/x" }
      shift_y = channels.find{|e| e.name == "#{t_name}/shift/x" }
    
      raise "Cannot find shift channels for #{t_name}" unless shift_x && shift_y
    
      # Find the shift at the same place where our base Track keyframe is
      kf_x, kf_y = [shift_x, shift_y].map do | chan |
        chan.find {|f| f.frame == base_kf[0] }
      end
    
      # Now, if there are no matching keyframes just use the first value present
      base_x, base_y = unless kf_x && kf_y
        [base_kf[1], base_kf[2]]
      else
        [kf_x.value, kf_y.value]
      end
      
      tuples = shift_x.map do |e|
        match_y = shift_y.find do | yf |
          yf.frame == e.frame
        end
        
        if !match_y
          nil
        else
          [e.frame, e.value, match_y.value]
        end
      end.compact
    
      t.keyframes = tuples.map do | (at, x, y) |
        K.new(:frame => at, :abs_x => (base_x + x.to_f), :abs_y => (base_y + y.to_f))
      end
      
      return t
      
  end
  
  
end