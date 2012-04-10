# -*- encoding : utf-8 -*-
class Tracksperanto::Middleware::LensDisto < Tracksperanto::Middleware::Base
  include Tracksperanto::UVCoordinates
  
  class Vector2 < Struct.new(:x, :y)
  end
  
  class RF < Struct.new(:r, :f)
    def inspect
      '(%0.3f %0.3f)' % [r, f]
    end
    
    def m
      r * f
    end
  end
  
  parameter :k,  :cast => :float, :desc => "Quartic distortion coefficient", :default => 0
  parameter :kcube,  :cast => :float, :desc => "Cubic distortion coefficient", :default => 0
  parameter :remove, :cast => :bool, :desc => "Remove distortion instead of adding it"
  
  STEPS = 256
  
  def self.action_description
    "Apply or remove lens distortion with the Syntheyes algorithm"
  end
  
  def start_export(w, h)
    @width, @height = w, h
    @aspect = @width.to_f / @height
    
    # Generate the lookup table
    @lut = [RF.new(0.0, 1.0)]
    max_r = @aspect + 1
    
    increment = max_r / STEPS
    r = 0
    STEPS.times do | mult |
      r += increment
      @lut.push(RF.new(r, disto_radius(r)))
    end
    
    @lut.inspect
    super
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    x, y =  remove ? undisto(float_x, float_y) : disto(float_x, float_y)
    super(frame, x, y, float_residual)
  end
  
  private
  
  def with_uv(x, y)
    vec = Vector2.new(convert_to_uv(x, @width), convert_to_uv(y, @height))
    yield(vec)
    [convert_from_uv(@width, vec.x), convert_from_uv(@height, vec.y)]
  end
  
  # Radius is equal to aspect at the rightmost extremity
  def disto_radius(r)
    r2 = r ** 2
    # Skipping the square root speeds things up if we don't need it
    f = if kcube.abs > 0.00001
      1 + (r2 * (k + kcube * Math.sqrt(r2)));
    else
      1 + (r2 * k);
    end
  end
  
  def disto(x, y)
    with_uv(x, y) do | pt |
      # Get the radius of the point
      x = pt.x * @aspect
      r = Math.sqrt(x.abs**2 + pt.y.abs**2)
      
      # Find the good tuples to interpolate on
      f = disto_interpolated(r)
      
      pt.x = pt.x * f
      pt.y = pt.y * f
    end
  end
  
  
  def undisto(x, y)
    with_uv(x, y) do | pt |
      # Get the radius of the point
      x = pt.x * @aspect
      r = Math.sqrt(x.abs**2 + pt.y.abs**2)
      
      # Find the good tuples to interpolate on
      f = undisto_interpolated(r)
      
      pt.x = pt.x / f
      pt.y = pt.y / f
    end
  end
  
  def disto_interpolated(r)
    left , right = nil, nil
    @lut.each_with_index do | rf, i |
      if rf.r > r
        right = rf
        left = @lut[i -1]
        return lerp(r, left.r, right.r, left.f, right.f)
      end
    end
  end
  
  def undisto_interpolated(r)
    left , right = nil, nil
    @lut.each_with_index do | xf, i |
      if xf.m > r
        right = xf
        left = @lut[i -1]
        return lerp(r, left.m, right.m, left.f, right.f)
      end
    end
  end
  
  def lerp(x, left_x, right_x, left_y, right_y)
    dx = right_x - left_x
    dy = right_y - left_y
    t = (x - left_x) / dx
    left_y + (dy * t)
  end
  
  
end
