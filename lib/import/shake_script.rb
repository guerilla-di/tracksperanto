require File.dirname(__FILE__) + "/shake_grammar/lexer"
require File.dirname(__FILE__) + "/shake_grammar/catcher"

class Tracksperanto::Import::ShakeScript < Tracksperanto::Import::Base
  include Tracksperanto::ShakeGrammar
  
  class Traxtractor < Catcher
    include Tracksperanto::ZipTuples
    
    class << self
      attr_accessor :accumulator
    end
    self.accumulator = []
    
    # For Linear() curve calls. If someone selected JSpline or Hermite it's his problem.
    # We put the frame number at the beginning since it works witih oru tuple zipper
    def linear(first_arg, *keyframes)
      keyframes.map do | kf |
        [kf[1][1], kf[0][1]]
      end
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
      collect_trackers_from(trackers)
      true
    end
    
    private
    
    def collect_trackers_from(array)
      parameters_per_node = 16
      nb_trackers = array.length / parameters_per_node
      nb_trackers.times do | idx |
        from_index, to_index = (idx * parameters_per_node), (idx+1) * parameters_per_node
        tracker_args = array[from_index...to_index]
        collect_tracker(*tracker_args)
      end
    end
    
    def collect_tracker(name, x_curve, y_curve, corr_curve, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12)
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
    Traxtractor.new(script_io)
    
    trackers
  end
end