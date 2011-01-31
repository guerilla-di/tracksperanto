# Scales the comp being exported by a specific factor, together with the tracker keyframes
class Tracksperanto::Middleware::Scaler < Tracksperanto::Middleware::Base
  DEFAULT_FACTOR = 1
  
  attr_accessor :x_factor, :y_factor
  cast_to_float :x_factor, :y_factor
  
  # Called on export start
  def start_export( img_width, img_height)
    set_residual_factor
    @w, @h = (img_width * x_factor).to_i.abs, (img_height * y_factor).to_i.abs
    super(@w, @h)
  end
  
  def y_factor
    @y_factor || DEFAULT_FACTOR
  end
  
  def x_factor
    @x_factor || DEFAULT_FACTOR
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    return super if @y_factor == DEFAULT_FACTOR && @x_factor == DEFAULT_FACTOR
    
    super(frame,
      x_factor < 0 ? (@w + (float_x * x_factor)) : (float_x * x_factor),
      y_factor < 0 ? (@h + (float_y * y_factor)) : (float_y * y_factor),
      (float_residual * @residual_factor)
    )
  end
  
  private
    def set_residual_factor
      @residual_factor = Math.sqrt((x_factor ** 2) + (y_factor ** 2))
    end
end