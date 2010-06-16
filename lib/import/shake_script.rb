require File.dirname(__FILE__) + "/shake_grammar/lexer"
require File.dirname(__FILE__) + "/shake_grammar/catcher"
class Tracksperanto::Import::ShakeScript < Tracksperanto::Import::Base
  
  def self.human_name
    "Shake .shk script file"
  end
  
  def self.distinct_file_ext
    ".shk"
  end
  
  # Extractor. The injection should be an array of two elements: the array collecting
  # trackers and the progress proc
  class Traxtractor < Tracksperanto::ShakeGrammar::Catcher
    include Tracksperanto::ZipTuples
    
    # Normally, we wouldn't need to look for the variable name from inside of the funcall. However,
    # in this case we DO want to take this shortcut so we know how the tracker node is called
    def push(atom)
      return super unless (atom.is_a?(Array)) && 
           (atom[0] == :assign) &&
           (atom[2][0] == :retval) &&
           (atom[2][1][0] == :trk)
      node_name = atom[1][-1]
      trackers = atom[2][1][1..-1]
      trackers.map do | tracker |
       tracker.name = [node_name, tracker.name].join("_")
       sentinel[0].push(tracker)
      end
    end
    
    # For Linear() curve calls. If someone selected JSpline or Hermite it's his problem.
    # We put the frame number at the beginning since it works witih oru tuple zipper
    def linear(extrapolation_type, *keyframes)
      report_progress("Translating Linear animation")
      keyframes.map { |kf| [kf.at, kf.value] }
    end
    alias_method :nspline, :linear
    alias_method :jspline, :linear
    
    # Hermite interpolation looks like this
    # Hermite(0,[1379.04,-0.02,-0.02]@1,[1379.04,-0.03,-0.03]@2)
    # The first value in the array is the keyframe value, the other two are
    # tangent positions (which we discard)
    def hermite(extrapolation_type, *keyframes)
      report_progress("Translating Hermite curve, removing tangents")
      keyframes.map{ |kf| [kf.at, kf.value[0]] }
    end
    
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
        referenceTolerance, referenceBehavior, failureTolerance, failureBehavior, limitProcessing, referencFrame, s1, s2,
        s3, s4, s5, s6, *trackers)
      
      report_progress("Parsing Tracker node")
      collect_trackers_from(trackers).unshift(:trk)
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
      sentinel[1].call(with_message) if sentinel[1]
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
    
    def collect_stabilizer_tracker(name, x_curve, y_curve)
      return if (x_curve == :unknown || y_curve == :unknown)
      
      keyframes = zip_curve_tuples(x_curve, y_curve).map do | (frame, x, y) |
        Tracksperanto::Keyframe.new(:frame => frame - 1, :abs_x => x, :abs_y => y)
      end
      
      Tracksperanto::Tracker.new(:name => name, :keyframes => keyframes)
    end
    
    def collect_tracker(name, x_curve, y_curve, corr_curve, *discard)
      unless x_curve.is_a?(Array) && y_curve.is_a?(Array)
        report_progress("Tracker #{name} had no anim or unsupported interpolation and can't be recovered")
        return
      end
      
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
  end
  
  def parse(script_io)
    trackers = []
    progress_proc = lambda{|msg| report_progress(msg) }
    Traxtractor.new(script_io, [trackers, progress_proc])
    trackers
  end
  
end