require 'strscan'

class Tracksperanto::Import::ShakeScript < Tracksperanto::Import::Base
  
  # Allow literal strings instead of Regexps
  class SloppyParser < StringScanner
    def skip_until(pattern)
      pattern.is_a?(String) ? super(/#{Regexp.escape(pattern)}/m) : super(pattern)
    end

    def scan_until(pattern)
      pattern.is_a?(String) ? super(/#{Regexp.escape(pattern)}/m) : super(pattern)
    end
  end

  class ValueAt
    attr_accessor :value, :frame
    def self.from_string(str)
      v = new
      val_s, frame_s = str.scan(/(.+)@(\d+)/).to_a.flatten
      v.value, v.frame = val_s.to_f, frame_s.to_i
      v
    end
  end

  class CurveParser < SloppyParser
    BLOCK_ENDS = /\d,|\)/
    
    attr_reader :values
    def initialize(with_curve_arg)
      @values = []
      
      super(with_curve_arg.to_s)
      
      # Skip the interpolation name, we assume it to be linear anyway
      skip_until '('
      
      # Skip the first defining parameter whatever that might be
      skip_until ','
      
      loop do
        break unless (value_at = scan_until(BLOCK_ENDS))
        # Grab the value
        val = ValueAt.from_string(value_at)
        
        @values << val
      end
    end

  end
  
  class TrackerParser < SloppyParser
    attr_reader :x_curve, :y_curve, :c_curve, :name
    
    def initialize(with_tracker_args)
      super(with_tracker_args)

      # Name me!
      @name = scan_until(/(\w+) /).strip

      # All the tracker arguments
      17.times { skip_until ',' } # input data
      
      # Grab the curves
      @x_curve, @y_curve, @c_curve = (0..2).map{ CurveParser.new(scan_until('),')).values }
      
      # if the next argument is an integer, we reached the end of the tracks. If not - make a nested one.
    end
    
    def curves
      [@x_curve, @y_curve, @c_curve]
    end
  end
  
  class TrackParser < SloppyParser
    def initialize(with_tracker_block)
      # scan until the first " - name of the track
      skip_until  ','
      # scan values
      # discard the 8 box determinators
      7.times { skip_until  ',' }
      # discard the box animation
      2.times { skip_until  ',' }
    end
  end
  
  TRACKER_PATTERN = /((\w+) = Tracker\(([^;]+))/m
  
  def self.parse(sript_file_content)
    
    trackers = []
    
    sript_file_content.scan(TRACKER_PATTERN).each_with_index do | tracker_text_block, idx |
      
      parser = TrackerParser.new(tracker_text_block.to_s)
      
      tracker = Tracksperanto::Tracker.new{|t| t.name = parser.name }
      
      x_keyframes, y_keyframes, residual_keyframes = TrackerParser.new(tracker_text_block.to_s).curves
      x_keyframes.each_with_index do | value_at, kf_index |
        
        # Find the Y keyframe with the same frame
        matching_y = y_keyframes.find{|f| f.frame == value_at.frame }
        
        # Find the correlation keyframe with the same frame
        matching_residual = residual_keyframes.find{|f| f.frame == value_at.frame }
        
        # Skip frame if only one keyframe is present
        if !matching_y
          STDERR.puts "Cannot find matching Y for frame #{value_at.frame}"
          next
        end
        
        tracker.keyframes << Tracksperanto::Keyframe.new do |k|
          k.frame = (value_at.frame - 1)
          k.abs_x = value_at.value
          k.abs_y = matching_y.value
          k.residual = 1 - (matching_residual.value rescue 1.0)
        end
      end
      
      trackers << tracker
    end
    
    trackers
  end
end