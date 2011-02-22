# Internal representation of a tracker point with keyframes. A Tracker is an array of Keyframe objects
# with a few methods added for convenience
class Tracksperanto::Tracker < DelegateClass(Array)
  include Tracksperanto::Casts
  include Tracksperanto::BlockInit
  include Comparable
  
  # Contains the name of the tracker
  attr_accessor :name
  cast_to_string :name
  
  def initialize(object_attribute_hash = {})
    @name = "Tracker"
    __setobj__(Array.new)
    super
  end
  
  def keyframes=(new_kf_array)
    __setobj__(new_kf_array.dup)
  end

  alias_method :keyframes, :__getobj__
  
  # Trackers sort by the position of the first keyframe
  def <=>(other_tracker)
    self[0].frame <=> other_tracker[0].frame
  end
  
  # Automatically truncate spaces in the tracker
  # name and replace them with underscores
  def name=(n)
    @name = n.to_s.gsub(/(\s+)/, '_')
  end
   
  # Create and save a keyframe in this tracker
  def keyframe!(options)
    push(Tracksperanto::Keyframe.new(options))
  end
  
  def inspect
    "<T #{name.inspect} with #{length} keyframes>"
  end
  
  # Hack - prevents the Tracker to be flattened into keyframes
  # when an Array of Trackers gets Array#flatten'ed
  def to_ary; end  
  private :to_ary
end