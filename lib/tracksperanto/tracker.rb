# Internal representation of a tracker
class Tracksperanto::Tracker < DelegateClass(Array)
  include Tracksperanto::Casts
  include Comparable
  
  # Contains the name of the tracker
  attr_accessor :name
  cast_to_string :name
  
  def initialize(object_attribute_hash = {})
    @name = "Tracker"
    __setobj__(Array.new)
    object_attribute_hash.map { |(k, v)| send("#{k}=", v) }
    yield(self) if block_given?
  end
  
  def keyframes=(new_kf_array)
    __setobj__(new_kf_array.dup)
  end
  
  def keyframes
    __getobj__
  end
  
  # Trackers sort by the position of the first keyframe
  def <=>(other_tracker)
    self[0].frame <=> other_tracker[0].frame
  end
  
  # Create and save a keyframe in this tracker
  def keyframe!(options)
    push(Tracksperanto::Keyframe.new(options))
  end
  
  def inspect
    "<T #{name.inspect} with #{length} keyframes>"
  end
end