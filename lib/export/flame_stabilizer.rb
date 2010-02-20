class Tracksperanto::Export::FlameStabilizer < Tracksperanto::Export::Base
  
  COLOR = "50 50 50"
  DATETIME_FORMAT = '%a %b %d %H:%M:%S %Y'
  
  def self.desc_and_extension
    "flame.stabilizer"
  end
  
  def self.human_name
    "Flame/Smoke 2D Stabilizer setup"
  end
  
  def start_export( img_width, img_height)
    @counter = 0
    @width, @height = img_width, img_height
    @temp = Tempfile.new("flamexp")
    @writer = Tracksperanto::FlameBuilder.new(@temp)
  end
  
  def end_export
    @writer = Tracksperanto::FlameBuilder.new(@io)
    
    # Now we know how many trackers we have so we can write the header
    # data along with NbTrackers
    write_header
    
    # Now write everything that we accumulated earlier into the base IO
    @temp.rewind
    @io.write(@temp.read) until @temp.eof?
    @temp.close!
    
    # Send the ChannelEnd command and list the trackers
    @writer.channel_end
    @counter.times do |i|
      @writer.tracker(i) do |t|
        t.active true
        t.color_hash!("colour", 0, 100, 0)
        t.fixed_ref true
        t.fixed_x false
        t.fixed_y false
        t.tolerance 100
      end
    end
  end
  
  def start_tracker_segment(tracker_name)
    @counter += 1
    @tracker_name = tracker_name
    @x_values, @y_values = [], []
    @write_first_frame = true
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    if @write_first_frame
      write_first_frame(abs_float_x, abs_float_y, frame)
      # For Flame to recognize the reference frame of the Shift channel
      # we need it to contain zero as an int, not as a float. The shift proceeds
      # from there.
      @x_values << [frame, 0]
      @y_values << [frame, 0]
      @write_first_frame = false
    else
      @x_values << [frame, (@base_x - abs_float_x)]
      @y_values << [frame, (@base_y - abs_float_y)]
    end
  end
  
  def end_tracker_segment
    # We write these at tracker end since we need to know in advance
    # how many keyframes they should contain
    write_shift_channel("shift/x", @x_values, @base_x)
    write_shift_channel("shift/y", @y_values, @base_y)
  end
  
  private
  
  # The shift channel is what determines how the tracking point moves.
  def write_shift_channel(name_without_prefix, values, base)
    @writer.channel(prefix(name_without_prefix)) do | c |
      c.extrapolation :constant
      c.value values[0][1]
      c.key_version 1
      c.size values.length
      values.each_with_index do | (f, v), i |
        c.key(i) do | k |
          k.frame(f + 1)
          k.value(v)
          k.interpolation :linear
          k.left_slope 2.4
          k.right_slope 2.4
        end
      end
    end
  end
  
  def prefix(tracker_channel)
    ["tracker#{@counter}", tracker_channel].join("/")
  end
  
  def write_header
    @writer.stabilizer_file_version "5.0"
    @writer.creation_date(Time.now.strftime(DATETIME_FORMAT))
    @writer.linebreak!(2)
    
    @writer.nb_trackers(@counter)
    @writer.selected 0
    @writer.frame_width @width
    @writer.frame_height @height
    @writer.auto_key true
    @writer.motion_path true
    @writer.icons true
    @writer.auto_pan false # hate it!
    @writer.edit_mode 0
    @writer.format 0
    @writer.color_hash!("padding", 0, 100, 0)
    @writer.oversampling false
    @writer.opacity 50
    @writer.zoom 3
    @writer.field false
    @writer.backward false
    @writer.anim
  end
  
  def write_first_frame(x, y, f)
    @base_x, @base_y = x, y
    
    tx, ty = @width / 2, @height / 2
    
    # track determines where the tracking box is, and should be in the center
    # of the image for Flame to compute all other shifts properly
    %w( track/x track/y).map(&method(:prefix)).zip([tx, ty]).each do | cname, default |
      @writer.channel(cname) do | c |
        c.extrapolation("constant")
        c.value(default.to_i)
        c.colour(COLOR)
      end
    end
    
    # The size of the tracking area
    %w( track/width track/height ).map(&method(:prefix)).each do | channel_name |
      @writer.channel(channel_name) do | c |
        c.extrapolation :linear
        c.value 15
        c.colour COLOR
      end
    end
    
    # The size of the reference area
    %w( ref/width ref/height).map(&method(:prefix)).each do | channel_name |
      @writer.channel(channel_name) do | c |
        c.extrapolation :linear
        c.value 10
        c.colour COLOR
      end
    end
    
    # The Ref channel contains the reference for the shift channel in absolute
    # coordinates, and is set as float. Since we do not "snap" the tracker in
    # the process it's enough for us to make one keyframe in the ref channels
    # at the same frame as the first shift keyframe
    %w( ref/x ref/y).map(&method(:prefix)).zip([x, y]).each do | cname, default |
      @writer.channel(cname) do | c |
        c.extrapolation("constant")
        c.value(default)
        c.colour(COLOR)
        c.key_version 1
        c.size 1
        c.key(0) do | k |
          k.frame 1
          k.value default
          k.interpolation :constant
          k.left_slope 2.4
          k.right_slope 2.4
        end
      end
    end
    
    # This is used for deltax and deltay (offset tracking).
    # We set it to zero and lock
    %w( ref/dx ref/dy).map(&method(:prefix)).each do | chan, v |
      @writer.channel(chan) do | c |
        c.extrapolation("constant")
        c.value 0
        c.colour(COLOR)
        c.size 2
        c.key_version 1
        c.key(0) do | k |
          k.frame 0
          k.value 0
          k.value_lock true
          k.delete_lock true
          k.interpolation :constant
        end
        c.key(1) do | k |
          k.frame 1
          k.value 0
          k.value_lock true
          k.delete_lock true
          k.interpolation :constant
        end
      end # Chan block
      
      # None
      %w(offset/x offset/y).map(&method(:prefix)).each do | c |
        @writer.channel(c) do | chan |
          chan.extrapolation :constant
          chan.value 0
        end
      end
    end #Iter
  end # Meth
  
end
