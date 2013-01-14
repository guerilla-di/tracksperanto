# -*- encoding : utf-8 -*-
# Export each tracker as a moving 3dsmax null
class Tracksperanto::Export::Maxscript < Tracksperanto::Export::Base
  
  MULTIPLIER = 10.0
  IMAGE_PLANE = 'new_plane = convertToPoly (plane width:%0.5f length:%0.5f lengthsegs:1 widthsegs:1 name:"TracksperantoPlane" backFaceCull:True)'

  def self.desc_and_extension
    "3dsmax_nulls.ms"
  end
  
  def self.human_name
    "Autodesk 3dsmax script for nulls on an image plane"
  end
  
  def start_export(w, h)
    # Pixel sizes are HUGE. Hence we downscale
    @factor = (1 / w.to_f) * MULTIPLIER
    @true_width, @true_height = w * @factor, h * @factor
    
    # Generate a Plane primitive
    @io.puts(IMAGE_PLANE % [@true_width, @true_height])

  end
  
  def start_tracker_segment(tracker_name)
    @t = tracker_name
    @initalized = false
    @io.puts("-- Data for tracker %s" % @t)
    @io.puts('animate on (')
  end
  
  def end_tracker_segment
    # Parent the null to the image plane
    #@tracker_names.push(@t)
    @io.puts(')')
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    coords = get_coordinates(abs_float_x, abs_float_y)
    coords.unshift @t
    if !@initalized
      @io.puts('pt = Point name:"%s" pos:[%0.5f,%0.5f,0.000] size:1.000000 axistripod:off centermarker:on isSelected:on' % coords)
      @initalized = true
    end
    @io.puts('at time %d pt.pos.x = %.5f' % [frame, coords[1]])
    @io.puts('at time %d pt.pos.y = %.5f' % [frame, coords[2]])
  end
  
  def end_export
    # Create a Model group and parent all the trackers and the image plane to it
    @io.puts('animate off')
    @io.puts('EnableSceneRedraw()')
  end
  
  private
  
  def get_coordinates(x, y)
    # Get the coords multiplied by factor, and let the scene origin be the center of the composition
    [(x * @factor) - (@true_width / 2), y * @factor - (@true_height / 2)]
  end
end
