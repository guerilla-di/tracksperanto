require 'stringio'

class Tracksperanto::Import::Base
  def self.inherited(by)
    Tracksperanto.importers << by
    super
  end
  
  # Should return an array of Tracksperanto::Tracker objects
  def self.parse(track_file_content)
    []
  end
end