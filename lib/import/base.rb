require 'stringio'

class Tracksperanto::Import::Base
  include Tracksperanto::Safety
  
  # The original width of the tracked image
  # Some importers need it
  attr_accessor :width
  
  # The original height of the original image.
  # Some importers need it
  attr_accessor :height
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