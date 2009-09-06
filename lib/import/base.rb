require 'stringio'

class Tracksperanto::Import::Base
  include Tracksperanto::Safety
  include Tracksperanto::Casts
  
  # The original width of the tracked image
  # Some importers need it
  cast_to_int :width
  
  # The original height of the original image.
  # Some importers need it
  cast_to_int :height
  
  # Safety on readers
  safe_reader :width, :height
  
  def self.inherited(by)
    Tracksperanto.importers << by
    super
  end
  
  # Should return an array of Tracksperanto::Tracker objects
  def parse(track_file_content)
    []
  end
end