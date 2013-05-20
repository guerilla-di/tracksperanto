# -*- encoding : utf-8 -*-
require 'flame_channel_parser'

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
    
    begin
      report_progress("Assembling tracker curves from channels")
      scavenge_trackers_from_channels(channels, names) {|t| yield(t) }
    ensure
      channels.clear
    end
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
    
    # Extracts the animation channels and stores them in Obufs
    # keyed by the channel path (like "tracker1/ref/x")
    def extract_channels_from_stream(io)
      parser = StabilizerParser.new
      parser.logger_proc = method(:report_progress)
      
      channel_map = {}
      parser.parse(io) do | channel |
        # Serialize the channel and store it on disk.
        # Flame stabilizers are NOT likely to contain hundreds of
        # trackers unless they were machine-exported from something,
        # but we need to be memory-aware when we do things like this.
        # On our test suite we lose half a second on disk IO overhead
        # of the Obuf here, which is an acceptable compromise.
        # To get rid of the disk-based cache just toss the outer
        # Obuf constructor and pass in an Array
        channel_map[channel.path] = Obuf.new([channel])
      end
      
      channel_map
    end
    
    def scavenge_trackers_from_channels(channel_map, names)
      # Use Hash#keys.sort because we want a consistent export order
      # irregardless of the Ruby version in use
      # (hash keys are ordered on 1.9 and not ordered on 1.8)
      channel_map.keys.sort.each do |c|
        next unless c =~ /\/ref\/x$/
        
        report_progress("Detected reference channel #{c.inspect}")
        
        extracted_tracker = grab_tracker(channel_map, c)
        if extracted_tracker
          yield(extracted_tracker)
        end
      end
    end
    
    def channel_to_frames_and_values(chan)
      chan.map{|key| [key.frame, key.value]}
    end
    
    def grab_tracker(channel_map, ref_x_channel_name)
      t = Tracksperanto::Tracker.new(:name => ref_x_channel_name.split('/').shift)
      
      report_progress("Extracting tracker #{t.name}")
      
      shift_x = channel_map["#{t.name}/shift/x"][0]
      shift_y = channel_map["#{t.name}/shift/y"][0]
      ref_x = channel_map["#{t.name}/ref/x"][0]
      ref_y = channel_map["#{t.name}/ref/y"][0]
      
      # Collapse separate X and Y curves into series of XY values
      shift_tuples = zip_curve_tuples(channel_to_frames_and_values(shift_x), channel_to_frames_and_values(shift_y))
      ref_tuples = zip_curve_tuples(channel_to_frames_and_values(ref_x), channel_to_frames_and_values(ref_y))
      
      # If the channels are just empty go to next tracker
      return if shift_tuples.empty? || ref_tuples.empty?
      
      report_progress("Detecting base value")
      base_x, base_y =  find_base_x_and_y(ref_tuples, shift_tuples)
      
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
    
    def find_base_x_and_y(ref_tuples, shift_tuples)
      base_ref_tuple = ref_tuples.find do | track_tuple |
        shift_tuples.find { |shift_tuple| shift_tuple[0] == track_tuple[0] }
      end
      (base_ref_tuple || ref_tuples[0])[1..2]
    end
end
