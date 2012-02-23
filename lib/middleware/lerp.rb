# -*- encoding : utf-8 -*-
# This middleware adds linearly interpolated keyframes BETWEEN the keyframes passing through the exporter
class Tracksperanto::Middleware::Lerp < Tracksperanto::Middleware::Base
  
  def self.action_description
    "Interpolate missing keyframes of all the trackers"
  end
  
  def end_tracker_segment
    @last_f, @last_x, @last_y, @last_res = nil, nil, nil, nil
    super
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    
    if @last_f && (frame - @last_f > 1) # Interpolate!
      interpolated_frames = []
      interpolated_x = []
      lerp(@last_f, @last_x, frame, float_x) do | interp_f, interp_x |
        interpolated_frames << interp_f
        interpolated_x << interp_x
      end
      
      interpolated_y = []
      lerp(@last_f, @last_y, frame, float_y) do | interp_f, interp_y |
        interpolated_y << interp_y
      end
      
      interpolated_res = []
      lerp(@last_f, @last_res, frame, float_residual) do | interp_f, interp_res |
        interpolated_res << interp_res
      end
      
      tuples = interpolated_frames.zip(interpolated_x).zip(interpolated_y).zip(interpolated_res).map{|e| e.flatten }
      tuples.each do | f, x, y, r |
        super(f.to_i, x, y, r)
      end
    else
      super(frame, float_x + (@x_shift || 0), float_y + (@y_shift || 0), float_residual)
    end
    
    @last_f, @last_x, @last_y, @last_res = frame, float_x, float_y, float_residual
  end
  
  private
    # Do a simple linear interpolxion. The function will yield
    # the interim X and Y, one tuple per whole value between the set points,
    # and return the last tuple (so you can return-assign from it in a loop)
    def lerp(last_x, last_y, x, y) #:yields: interp_x, interp_y
      if last_x.nil?
        yield(x, y)
      else
        gap_size = x - last_x
        increment = (y.to_f - last_y) / gap_size.to_f
        (1..gap_size).each do | index |
          yield(last_x + index, last_y + (increment * index))
        end
      end

      return [x, y]
    end
end
