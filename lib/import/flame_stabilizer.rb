class Tracksperanto::Import::FlameStabilizer < Tracksperanto::Import::Base
  
  # Flame setups contain clear size indications
  def self.autodetects_size?
    true
  end
  
  def self.distinct_file_ext
    ".stabilizer"
  end
  
  def self.human_name
    "Flame .stabilizer file"
  end
  
  def each
    report_progress("Extracting setup size")
    self.width, self.height = extract_width_and_height_from_stream(@io)
    report_progress("Extracting all animation channels")
    channels, names = extract_channels_from_stream(@io)
    
    raise "A channel was nil" if channels.find{|e| e.nil? }
    
    report_progress("Assembling tracker curves from channels")
    scavenge_trackers_from_channels(channels, names) {|t| yield(t) }
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
    
    # We subclass the standard parser for a couple of reasons - we want to only parse the needed channels
    # AND we want to provide progress reports
    class StabilizerParser < FlameChannelParser::Parser
      USEFUL_CHANNELS = %w( /shift/x /shift/y /ref/x /ref/y ).map(&Regexp.method(:new))
      
      # This method tells the importer whether a channel that has been found in the source
      # setup is needed. If that method returns ++false++ the channel will be discarded and not
      # kept in memory. Should you need to write a module that scavenges other Flame animation channels
      # inherit from this class and rewrite this method to either return +true+ always (then all the channels
      # will be recovered) or to return +true+ only for channels that you actually need.
      def channel_is_useful?(channel_name)
        USEFUL_CHANNELS.any?{|e| channel_name =~ e }
      end
    end
    
    def extract_channels_from_stream(io)
      parser = StabilizerParser.new(&method(:report_progress))
      channels = parser.parse(io)
      [channels, channels.map{|c| c.path }]
    end
    
    def scavenge_trackers_from_channels(channels, names)
      channels.each do |c|
        next unless c.name =~ /\/ref\/x/
        
        report_progress("Detected reference channel #{c.name}")
        
        t = grab_tracker(channels, c, names)
        yield(t) if t
      end
    end
    
    def channel_to_frames_and_values(chan)
      chan.map{|key| [key.frame, key.value]}
    end
    
    def grab_tracker(channels, track_x, names)
      t = Tracksperanto::Tracker.new(:name => track_x.name.split('/').shift)
      
      report_progress("Extracting tracker #{t.name}")
      
      # This takes a LONG time when we have alot of channels, we need a precache of
      # some sort to do this
      ref_idx = names.index("#{t.name}/ref/y")
      shift_x_idx = names.index("#{t.name}/shift/x")
      shift_y_idx = names.index("#{t.name}/shift/y")
      
      track_y = channels[ref_idx]
      shift_x = channels[shift_x_idx]
      shift_y = channels[shift_y_idx]
      
      shift_tuples = zip_curve_tuples(channel_to_frames_and_values(shift_x), channel_to_frames_and_values(shift_y))
      track_tuples = zip_curve_tuples(channel_to_frames_and_values(track_x), channel_to_frames_and_values(track_y))
      
      # If the channels are just empty go to next tracker
      return if shift_tuples.empty? || track_tuples.empty?
      
      report_progress("Detecting base value")
      base_x, base_y =  find_base_x_and_y(track_tuples, shift_tuples)
      
      total_kf = 1
      t.keyframes = shift_tuples.map do | (at, x, y) |
        # Flame keyframes are sort of minus-one based, so to start at frame 0
        # we need to decrement one frame, always. Also, the shift value is inverted!
        kf_x, kf_y = base_x - x.to_f, base_y - y.to_f
        
        report_progress("Extracting keyframe #{total_kf += 1} of #{t.name}")
        Tracksperanto::Keyframe.new(:frame => (at - 1), :abs_x => kf_x, :abs_y => kf_y)
      end
      
      return t
    end
    
    def find_base_x_and_y(track_tuples, shift_tuples)
      base_track_tuple = track_tuples.find do | track_tuple |
        shift_tuples.find { |shift_tuple| shift_tuple[0] == track_tuple [0] }
      end || track_tuples[0]
      base_track_tuple[1..2]
    end
end