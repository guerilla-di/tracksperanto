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
  
  # Replace all the keyframes of the tracker with new ones
  def keyframes=(new_kf_array)
    @frame_table = {}
    new_kf_array.each do | keyframe |
      @frame_table[keyframe.frame] = keyframe.abs_x, keyframe.abs_y, keyframe.residual
    end
  end
  
  # Returns an array of keyframes, ordered by their frame value.
  # WARNING: in older Tracksperanto versions the returned value was
  # a handle into the tracker object. Now it returns a copy of the tracker's keyframes
  # and modifications done to the array WILL NOT propagate to the tracker object itself.
  # If you need to replace a keyframe, use set(keyframe). If you need to replace the whole
  # keyframes array, use keyframes=(new_keyframes)
  def keyframes
    to_a
  end
  
  # Sets a keyframe. If an old keyframe exists at this frame offset it will be replaced.
  def set(kf)
    @frame_table[kf.frame] = [kf.abs_x, kf.abs_y, kf.residual]
  end
  
  # Iterates over keyframes
  def each
    ordered_frame_numbers.each do | frame |
      yield(extract_keyframe(frame))
    end
  end
  
  # Trackers sort by the position of the first keyframe
  def <=>(other_tracker)
    self.first_frame <=> other_tracker.first_frame
  end
  
  # Returns the first frame number this tracker contains (where the first keyframe is)
  def first_frame
    ordered_frame_numbers[0]
  end
  
  # Automatically truncate spaces in the tracker
  # name and replace them with underscores
  def name=(n)
    @name = n.to_s.gsub(/(\s+)/, '_')
  end
   
  # Create and save a keyframe in this tracker. The options hash is the same
  # as the one for the Keyframe constructor
  def keyframe!(options)
    kf = Tracksperanto::Keyframe.new(options)
    set(kf)
  end
  
  # Tells whether this tracker is empty or not
  def empty?
    @frame_table.empty?
  end
  
  # Fetch a keyframe at a spefiic offset.
  # NOTICE: not at a specific **frame** but at an offset in the frames table.
  # The frames table is ordered by frame order. If you need to fetch a keyframe at a specific frame,
  # use at_frame
  def [](offset)
    frame = ordered_frame_numbers[offset]
    return nil if frame.nil?
    
    extract_keyframe(frame)
  end
  
  # Fetch a keyframe at a specific frame. If no such frame exists nil will be returned
  def at_frame(at_frame)
    extract_keyframe(at_frame)
  end
  
  # Add a keyframe. Will raise a Dupe exception if the keyframe to be set will overwrite another one
  def push(kf)
    raise Dupe, "The tracker #{name.inspect} already contains a keyframe at #{kf.frame}" if @frame_table[kf.frame]
    set(kf)
  end
  
  def inspect
    "<T #{name.inspect} with #{length} keyframes>"
  end
  
  # Tells how many keyframes this tracker contains
  def length
    @frame_table.length
  end
  
  private
  
  def ordered_frame_numbers
    @frame_table.keys.sort
  end
  
  def extract_keyframe(frame)
    triplet = @frame_table[frame]
    return nil unless triplet
    
    Tracksperanto::Keyframe.new(:frame => frame, :abs_x => triplet[0], :abs_y => triplet[1], :residual => triplet[2])
  end
end