# Internal representation of a tracker point with keyframes. A Tracker is an array of Keyframe objects
# with a few methods added for convenience
class Tracksperanto::Tracker
  include Tracksperanto::Casts, Tracksperanto::BlockInit, Comparable, Enumerable
  
  # Contains the name of the tracker
  attr_accessor :name
  cast_to_string :name
  
  class Dupe < RuntimeError
  end
  
  def initialize(object_attribute_hash = {})
    @name = "Tracker"
    @frame_table = {}
    super
  end
  
  def keyframes=(new_kf_array)
    new_kf_array.each do | keyframe |
      @frame_table[keyframe.frame] = keyframe.abs_x, keyframe.abs_y, keyframe.residual
    end
  end
  
  def keyframes
    to_a
  end
  
  def each
    @frame_table.keys.sort.each do | frame |
      yield(extract_keyframe(frame))
    end
  end
  
  # Trackers sort by the position of the first keyframe
  def <=>(other_tracker)
    self.first_frame <=> other_tracker.first_frame
  end
  
  def first_frame
    @frame_table.keys.sort[0]
  end
  
  # Automatically truncate spaces in the tracker
  # name and replace them with underscores
  def name=(n)
    @name = n.to_s.gsub(/(\s+)/, '_')
  end
   
  # Create and save a keyframe in this tracker
  def keyframe!(options)
    kf = Tracksperanto::Keyframe.new(options)
    @frame_table[kf.frame] = [kf.abs_x, kf.abs_y, kf.residual]
  end
  
  def empty?
    @frame_table.empty?
  end
  
  def [](offset)
    frame = @frame_table.keys.sort[offset]
    return nil if frame.nil?
    
    extract_keyframe(frame)
  end
  
  def push(kf)
    raise Dupe, "The tracker #{name.inspect} already contains a keyframe at #{kf.frame}" if @frame_table[kf.frame]
    @frame_table[kf.frame] = [kf.abs_x, kf.abs_y, kf.residual]
  end
  
  def inspect
    "<T #{name.inspect} with #{length} keyframes>"
  end
  
  def length
    @frame_table.length
  end
  
  private
  
  def extract_keyframe(frame)
    triplet = @frame_table[frame]
    Tracksperanto::Keyframe.new(:frame => frame, :abs_x => triplet[0], :abs_y => triplet[1], :residual => triplet[2])
  end
end