class Tracksperanto::Middleware::Scaler < Tracksperanto::Middleware::Base
  DEFAULT_FACTOR = 1
  
  attr_accessor :x_factor, :y_factor
  
  # Called on export start
  def start_export( img_width, img_height)
    super( (img_width * x_factor), (img_height * y_factor))
  end
  
  def y_factor
    @y_factor || DEFAULT_FACTOR
  end
  
  def x_factor
    @x_factor || DEFAULT_FACTOR
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    # Compute the average factor
    residual_factor = (x_factor + y_factor) / 2
    super(frame, (float_x * x_factor), (float_y * y_factor), (float_residual * residual_factor))
  end
end