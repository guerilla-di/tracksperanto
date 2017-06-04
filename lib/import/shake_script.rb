require File.expand_path(File.dirname(__FILE__)) + "/shake_grammar/lexer"
require File.expand_path(File.dirname(__FILE__)) + "/shake_grammar/catcher"

class Tracksperanto::Import::ShakeScript < Tracksperanto::Import::Base
  
  def self.human_name
    "Shake .shk script file"
  end
  
  def self.distinct_file_ext
    ".shk"
  end
  
  def self.known_snags
    'Expressions in node parameters may cause parse errors or incomplete imports. ' +
    'Take care to remove expressions or nodes containing them first.'
  end
  
  def each
    s = Sentinel.new
    s.progress_proc = method(:report_progress)
    s.tracker_proc = Proc.new
    TrackExtractor.new(@io, s)
  end
  
  private
  
  #:nodoc:
  
  class Sentinel
    attr_accessor :start_frame, :tracker_proc, :progress_proc
    def start_frame
      @start_frame.to_i
    end
  end
  
  # Extractor. Here we define copies of Shake's standard node creation functions.
  class TrackExtractor < Tracksperanto::ShakeGrammar::Catcher
    include Tracksperanto::ZipTuples
    
    # SetTimeRange("-5-15") // sets time range of comp
    # We use it to avoid producing keyframes which start at negative frames
    def settimerange(str)
      sentinel.start_frame = str.to_i if str.to_i < 0
    end
    
    # Normally, we wouldn't need to look for the variable name from inside of the funcall. However,
    # in this case we DO want to take this shortcut so we know how the tracker node is called
    def push(atom)
      return super unless atom_is_tracker_assignment?(atom)
      
      node_name = atom[1][-1]
      trackers = atom[2][1][1..-1]
      trackers.map do | tracker |
        tracker.name = [node_name, tracker.name].join("_")
        # THIS IS THE MOST IMPORTANT THINGO
        sentinel.tracker_proc.call(tracker)
      end
    end
    
    # Find whether the passed atom includes a [:trk] on any level
    def deep_include?(array_or_element, atom_name)
      return false unless array_or_element.is_a?(Array)
      return true if array_or_element[0] == atom_name
      
      array_or_element.each do | elem |
         return true if deep_include?(elem, atom_name)
      end
      
      false
    end
    
    # An atom that is a tracker node will look like this
    # [:assign, [:vardef, "Stabilize2"], [:retval, [:trk, <T "track1" with 116 keyframes>, <T "track2" with 116 keyframes>, <T "track3" with 116 keyframes>, <T "track4" with 89 keyframes>]]]
    # a Stabilize though will look like this
    # [:assign, [:vardef, "Stabilize1"], [:retval, [:trk, <T "track1" with 116 keyframes>, <T "track2" with 116 keyframes>, <T "track3" with 116 keyframes>]]]
    def atom_is_tracker_assignment?(a)
      deep_include?(a, :trk)
    end
    
    # For Linear() curve calls. If someone selected JSpline or Hermite it's his problem.
    # We put the frame number at the beginning since it works witih oru tuple zipper
    def linear(extrapolation_type, *keyframes)
      report_progress("Translating Linear animation")
      remap_keyframes_against_negative_at!(keyframes)
      keyframes.map { |kf| [kf.at , kf.value] }
    end
    alias_method :nspline, :linear
    alias_method :jspline, :linear
    
    # Hermite interpolation looks like this
    # Hermite(0,[1379.04,-0.02,-0.02]@1,[1379.04,-0.03,-0.03]@2)
    # The first value in the array is the keyframe value, the other two are
    # tangent positions (which we discard)
    def hermite(extrapolation_type, *keyframes)
      report_progress("Translating Hermite curve, removing tangents")
      remap_keyframes_against_negative_at!(keyframes)
      keyframes.map{ |kf| [kf.at, kf.value[0]] }
    end
    
    def remap_keyframes_against_negative_at!(kfs)
      frame_start_of_script = sentinel.start_frame
      kfs.each{|k| k.at = (k.at - frame_start_of_script) }
    end
    private :remap_keyframes_against_negative_at!
    
    # image Tracker( 
    #   image In,
    #   const char * trackRange,
    #   const char * subPixelRes,
    #   const char * matchSpace,
    #   float referenceTolerance,
    #   const char * referenceBehavior,
    #   float failureTolerance,
    #   const char * failureBehavior,
    #   int limitProcessing,
    #   float referencFrame 
    #   ...
    #  );  
    def tracker(input, trackRange, subPixelRes, matchSpace,
        referenceTolerance, referenceBehavior, failureTolerance, failureBehavior, limitProcessing, referencFrame, 
        s1, s2, s3, s4, s5, s6, *trackers)
      flat_tracks = if (s1 == "v2.0") # The Shake version stupid Winfucks users didn't get
        trackers
      else
        [s1, s2, s3, s4, s4, s6] + trackers
      end
      
      report_progress("Parsing Tracker node")
      collect_trackers_from(flat_tracks).unshift(:trk)
    end
    
    # stabilize {
    #   image In,
    #   int applyTransform,
    #   int inverseTransform
    #   const char * trackType,
    #   float track1X,
    #   float track1Y,
    #   int stabilizeX,
    #   int stabilizeY,
    #   float track2X,
    #   float track2Y,
    #   int matchScale,
    #   int matchRotation,
    #   float track3X,
    #   float track3Y,
    #   float track4X,
    #   float track4Y,
    #   const char * xFilter,
    #   const char * yFilter,
    #   const char * transformationOrder,
    #   float motionBlur, 
    #   float shutterTiming,
    #   float shutterOffset,
    #   float referenceFrame,
    #   float aspectRatio,
    #   ...
    # };
    def stabilize(imageIn, applyTransform, inverseTransform, trackType,
      track1X, track1Y,
      stabilizeX, stabilizeY,
      track2X, track2Y,
      matchScale,
      matchRotation,
      track3X, track3Y,
      track4X, track4Y,
      *useless_args)
      
      report_progress("Parsing Stabilize node")
      [
        collect_stabilizer_tracker("track1", track1X, track1Y),
        collect_stabilizer_tracker("track2", track2X, track2Y),
        collect_stabilizer_tracker("track3", track3X, track3Y),
        collect_stabilizer_tracker("track4", track4X, track4Y),
      ].compact.unshift(:trk)
    end
    
    #  image = MatchMove( 
    #    Background,
    #    Foreground,
    #    applyTransform,
    #    "trackType",
    #    track1X,
    #    track1Y,
    #    matchX,
    #    matchY,
    #    track2X,
    #    track2Y,
    #    scale,
    #    rotation,
    #    track3X,
    #    track3Y,
    #    track4X,
    #    track4Y,
    #    x1, 
    #    y1,
    #    x2,
    #    y2,
    #    x3,
    #    y3,
    #    x4,
    #    y4,
    #    "xFilter",
    #    "yFilter",
    #    motionBlur, 
    #    shutterTiming,
    #    shutterOffset,
    #    referenceFrame,
    #    "compositeType",
    #    clipMode,
    #   "trackRange",
    #    "subPixelRes",
    #    "matchSpace",
    #    float referenceTolerance,
    #    "referenceBehavior",
    #    float failureTolerance,
    #    "failureBehavior",
    #    int limitProcessing,
    #    ...
    #  );
    def matchmove(bgImage, fgImage, applyTransform,
      trackType,
      track1X,
      track1Y,
      matchX,
      matchY,
      track2X,
      track2Y,
      scale,
      rotation,
      track3X,
      track3Y,
      track4X,
      track4Y, *others)
      
      report_progress("Parsing MatchMove node")
      [
        collect_stabilizer_tracker("track1", track1X, track1Y),
        collect_stabilizer_tracker("track2", track2X, track2Y),
        collect_stabilizer_tracker("track3", track3X, track3Y),
        collect_stabilizer_tracker("track4", track4X, track4Y),
      ].compact.unshift(:trk)
    end
    
    private
    
    def report_progress(with_message)
      sentinel.progress_proc.call(with_message)
    end
    
    def collect_trackers_from(array)
      parameters_per_node = 16
      nb_trackers = array.length / parameters_per_node
      
      (0...nb_trackers).map do | idx |
        from_index, to_index = (idx * parameters_per_node), (idx+1) * parameters_per_node
        tracker_args = array[from_index...to_index]
        tracker_args[0] = "#{tracker_args[0]}"
        collect_tracker(*tracker_args)
      end.compact
    end
    
    # Remove tuples which have more than 2 values, and tuples that
    # have non-Numeric members
    def clean_tuples(frame_and_value_tuples)
      frame_and_value_tuples.reject do | element |
        element.length > 2
      end.reject do | element |
        element.any?{|e| !e.is_a?(Numeric) }
      end 
    end
    
    def collect_stabilizer_tracker(name, x_curve, y_curve)
      return unless valid_curves?(x_curve, y_curve)
      
      report_progress("Assembling Stabilizer node tracker #{name}")
      
      keyframes = zip_curve_tuples(clean_tuples(x_curve), clean_tuples(y_curve)).map do | (frame, x, y) |
        Tracksperanto::Keyframe.new(:frame => frame - 1, :abs_x => x, :abs_y => y)
      end
      Tracksperanto::Tracker.new(:name => name, :keyframes => keyframes)
    end
    
    def collect_tracker(name, x_curve, y_curve, corr_curve, *discard)
      return unless valid_curves?(x_curve, y_curve)
      
      report_progress("Scavenging tracker #{name}")
      
      curve_set = combine_curves(x_curve, y_curve, corr_curve)
      
      keyframes = zip_curve_tuples(*curve_set).map do | (frame, x, y, corr) |
        Tracksperanto::Keyframe.new(:frame => frame - 1, :abs_x => x, :abs_y => y, :residual => (1 - corr.to_f))
      end
      
      Tracksperanto::Tracker.new(:name => name, :keyframes => keyframes)
    end
    
    def combine_curves(x, y, corr_curve)
      curve_set = [x, y]
      curve_set << corr_curve if (corr_curve.respond_to?(:length) && corr_curve.length >= x.length)
      curve_set
    end
    
    private
    
    def valid_curves?(x_curve, y_curve)
      return false if (x_curve == :unknown || y_curve == :unknown)
      return false unless x_curve.is_a?(Array) && y_curve.is_a?(Array)
      true
    end
    
  end
end
