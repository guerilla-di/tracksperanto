class Tracksperanto::Export::FlameStabilizer < Tracksperanto::Export::Base
  
  COLOR = "50 50 50"
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
    write_header
    
    # Now write everything that we accumulated earlier into the base IO
    @temp.rewind
    @io.write(@temp.read) until @temp.eof?
    @temp.close!
    
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
      @x_values << [frame, 0]
      @y_values << [frame, 0]
    else
      @x_values << [frame, (@base_x - abs_float_x)]
      @y_values << [frame, (@base_y - abs_float_y)]
    end
  end
  
  def end_tracker_segment
    write_shift_channel("shift/x", @x_values, @base_x)
    write_shift_channel("shift/y", @y_values, @base_y)
  end
  
  private
  
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
    @writer.creation_date(Time.now.strftime('%a %b %d %H:%M:%S %Y'))
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
    @write_first_frame = false
    @base_x, @base_y = x, y
    
    tx, ty = @width / 2, @height / 2
    %w( track/x track/y).map(&method(:prefix)).zip([tx, ty]).each do | cname, default |
      @writer.channel(cname) do | c |
        c.extrapolation("constant")
        c.value(default.to_i)
        c.colour(COLOR)
      end
    end
    
    %w( track/width track/height ).map(&method(:prefix)).each do | channel_name |
      @writer.channel(channel_name) do | c |
        c.extrapolation :linear
        c.value 15
        c.colour COLOR
      end
    end
    
    %w( ref/width ref/height).map(&method(:prefix)).each do | channel_name |
      @writer.channel(channel_name) do | c |
        c.extrapolation :linear
        c.value 10
        c.colour COLOR
      end
    end
    
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
      
      %w(offset/x offset/y).map(&method(:prefix)).each do | c |
        @writer.channel(c) do | chan |
          chan.extrapolation :constant
          chan.value 0
        end
      end
    end #Iter
  end # Meth
  
end
