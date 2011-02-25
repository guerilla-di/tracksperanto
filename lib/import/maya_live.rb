class Tracksperanto::Import::MayaLive < Tracksperanto::Import::Base
  
  # Maya Live exports and imports tracks in "aspect units", so a point at 0,0
  # will be at -1.78,-1 in MayaLive coordinates with aspect of 1.78. Therefore
  # we offer an override for the aspect being imported (if the pixels are not square)
  attr_accessor :aspect
  
  def self.human_name
    "Maya Live track export file"
  end
  
  def self.autodetects_size?
    true
  end
  
  COMMENT = /^# /
  
  def each
    io = Tracksperanto::ExtIO.new(@io)
    extract_width_height_and_aspect(io.gets_non_empty)
    
    while line = io.gets_and_strip
      if line =~ COMMENT
        yield(@last_tracker) if @last_tracker
        @last_tracker = Tracksperanto::Tracker.new(:name => line.gsub(/#{COMMENT} Name(\s+)/, ''))
        next
      end
      
      tracker_num, frame, x, y, residual = line.split
      
      abs_x, abs_y = aspect_values_to_pixels(x, y)
      @last_tracker.keyframe! :frame => frame, :abs_x => abs_x, :abs_y => abs_y,  :residual => set_residual(residual)
    end
    
    yield(@last_tracker) if @last_tracker
  end
  
  private
  
    def aspect_values_to_pixels(x, y)
      [
        (@width.to_f / 2.0) + (x.to_f * @x_unit.to_f),
        (@height.to_f / 2.0) + (y.to_f * @y_unit.to_f)
      ]
    end
    
    def extract_width_height_and_aspect(from_str)
      self.width, self.height = from_str.scan(/\d+/)
      @aspect ||= width.to_f / height.to_f
      @x_unit = width / (@aspect * 2)
      @y_unit = height / (1 * 2)
    end
    
    def set_residual(residual)
      (residual == "-1" ? 0 : residual)
    end
end