require File.dirname(__FILE__) + "/shake_grammar/lexer"
require File.dirname(__FILE__) + "/shake_grammar/catcher"

class Tracksperanto::Import::ShakeScript < Tracksperanto::Import::Base
  
  def self.human_name
    "Shake .shk script file"
  end
  
  def self.distinct_file_ext
    ".shk"
  end
  
  class Traxtractor < Tracksperanto::ShakeGrammar::Catcher
    include Tracksperanto::ZipTuples
    
    class << self
      attr_accessor :accumulator
      attr_accessor :progress_block
    end
    
    self.accumulator = []
    
    # For Linear() curve calls. If someone selected JSpline or Hermite it's his problem.
    # We put the frame number at the beginning since it works witih oru tuple zipper
    def linear(first_arg, *keyframes)
      report_progress("Translating Linear animation")
      keyframes.map do | kf |
        [kf[1][1], kf[0][1]]
      end
    end
    alias_method :nspline, :linear
    
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
      collect_trackers_from(get_variable_name, trackers)
      true
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
      node_name = get_variable_name
      collect_stabilizer_tracker("#{node_name}_track1", track1X, track1Y)
      collect_stabilizer_tracker("#{node_name}_track2", track2X, track2Y)
      collect_stabilizer_tracker("#{node_name}_track3", track3X, track3Y)
      collect_stabilizer_tracker("#{node_name}_track4", track4X, track4Y)
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
      node_name = get_variable_name
      collect_stabilizer_tracker("#{node_name}_track1", track1X, track1Y)
      collect_stabilizer_tracker("#{node_name}_track2", track2X, track2Y)
      collect_stabilizer_tracker("#{node_name}_track3", track3X, track3Y)
      collect_stabilizer_tracker("#{node_name}_track4", track4X, track4Y)
      
    end
    
    private
    
    def report_progress(with_message)
      self.class.progress_block.call(with_message) if self.class.progress_block
    end
    
    def collect_trackers_from(name, array)
      parameters_per_node = 16
      nb_trackers = array.length / parameters_per_node
      nb_trackers.times do | idx |
        from_index, to_index = (idx * parameters_per_node), (idx+1) * parameters_per_node
        tracker_args = array[from_index...to_index]
        tracker_args[0] = "#{name}_#{tracker_args[0]}"
        collect_tracker(*tracker_args)
      end
    end
    
    def collect_stabilizer_tracker(name, x_curve, y_curve)
      return if (x_curve == :unknown || y_curve == :unknown)
      
      keyframes = zip_curve_tuples(x_curve, y_curve).map do | (frame, x, y) |
        Tracksperanto::Keyframe.new(:frame => frame - 1, :abs_x => x, :abs_y => y)
      end
      
      t = Tracksperanto::Tracker.new(:name => name, :keyframes => keyframes )
      self.class.accumulator.push(t)
    end
    
    def collect_tracker(name, x_curve, y_curve, corr_curve, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12)
      unless x_curve.is_a?(Array) && y_curve.is_a?(Array)
        report_progress("Tracker #{name} had no anim or unsupported interpolation and can't be recovered")
        return
      end
      
      report_progress("Scavenging tracker #{name}")
      
      keyframes = zip_curve_tuples(x_curve, y_curve, corr_curve).map do | (frame, x, y, corr) |
        Tracksperanto::Keyframe.new(:frame => frame - 1, :abs_x => x, :abs_y => y, :residual => (1 - corr))
      end
      
      t = Tracksperanto::Tracker.new(:name => name, :keyframes => keyframes )
      self.class.accumulator.push(t)
    end
  end
  
  def parse(script_io)
    trackers = []
    
    Traxtractor.accumulator = trackers
    Traxtractor.progress_block = lambda{|msg| report_progress(msg) }
    Traxtractor.new(script_io)
    
    trackers
  end
end