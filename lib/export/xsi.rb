# Export each tracker as a moving Softimage|XSI null
class Tracksperanto::Export::XSI < Tracksperanto::Export::Base

  IMAGE_PLANE = 'Application.CreatePrim("Grid", "MeshSurface", "", "")
Application.SetValue("grid.Name", "ImagePlane", "")
Application.SetValue("ImagePlane.grid.ulength", %0.5f, "")
Application.SetValue("ImagePlane.grid.vlength", %0.5f, "")
Application.Rotate("", 90, 0, 0, "siRelative", "siLocal", "siObj", "siXYZ", "", "", "", "", "", "", "", 0, "")'
  
  MULTIPLIER = 10.0
  
  def self.desc_and_extension
    "xsi_nulls.py"
  end
  
  def self.human_name
    "Autodesk Softimage nulls Python script"
  end
  
  def start_export(w, h)
    # Pixel sizes are HUGE. Hence we downscale
    @factor = (1 / w.to_f) * MULTIPLIER
    @true_width, @true_height = w * @factor, h * @factor
    
    # Generate a Grid primitive
    @io.puts(IMAGE_PLANE % [@true_width, @true_height])
    @tracker_names = []
  end
  
  def start_tracker_segment(tracker_name)
    @t = tracker_name
    @io.puts("# Data for tracker %s" % @t)
    @io.puts 'Application.GetPrim("Null", "", "", "")'
    @io.puts('Application.SetValue("null.Name", "%s", "")' % @t)
    # Application.ToggleSelection("Track_Point_02", "", "")
    # Select the tracker that we will animate
    @io.puts('Application.SelectObj("%s", "", True)' % @t)
  end
  
  def end_tracker_segment
    # Parent the null to the image plane
    @tracker_names.push(@t)
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    coords = get_coordinates(abs_float_x, abs_float_y)
    @io.puts('Application.Translate("", %0.5f, %0.5f, 0, "siAbsolute", "siView", "siObj", "siXYZ", "", "", "", "", "", "", "", "", "", 0, "")'% coords)
    @io.puts('Application.SaveKeyOnKeyable("%s", %d, "", "", "", False, "")' % [@t, frame + 1])
  end
  
  def end_export
    # Create a Model group and parent all the trackers and the image plane to it
    @io.puts('Application.DeselectAll()')
    @io.puts('Application.AddToSelection("ImagePlane", "", "")')
    @tracker_names.each do | tracker_name |
      @io.puts('Application.AddToSelection("%s", "", "")' % tracker_name)
    end
    @io.puts('Application.CreateModel("", "", "", "")')
    @io.puts('Application.SetValue("Model.Name", "Tracksperanto", "")')
  end
  
  private
  
  def get_coordinates(x, y)
    # Get the coords multiplied by factor, and let the scene origin be the center of the composition
    [(x * @factor) - (@true_width / 2), y * @factor - (@true_height / 2)]
  end
end
