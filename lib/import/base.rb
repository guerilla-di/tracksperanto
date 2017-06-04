# The base class for all the import modules. By default, when you inherit from
# this class the inherited class will be included in the list of supported
# Tracksperanto importers. The API that an importer should present is very
# basic, and consists only of a few methods. The main method is
# `each`.
class Tracksperanto::Import::Base
  include Enumerable, Tracksperanto::Safety, Tracksperanto::Casts
  include Tracksperanto::BlockInit, Tracksperanto::ZipTuples, Tracksperanto::ConstName
  
  # Handle to the IO with data being parsed
  attr_accessor :io
  
  # Tracksperanto will assign a proc that reports the status of the import to the caller.
  # This block is automatically used by report_progress IF the proc is assigned. Should
  # the proc be nil, the report_progress method will just pass (so you don't need to check for nil
  # yourself)
  attr_accessor :progress_block
  
  # The original width and height of the tracked image.
  # If you need to know the width for your specific format and cannot autodetect it,
  # Trakcksperanto will assign the passed width and height to the importer object before running
  # the import. If not, you can replace the assigned values with your own. At the end of the import
  # procedure, Tracksperanto will read the values from you again and will use the read values
  # for determining the original comp size. +width+ and +height+ MUST return unsigned integer values after
  # the import completes
  attr_accessor :width, :height
  
  # These reader methods will raise when the values are nil
  cast_to_int :width, :height
  safe_reader :width, :height
  
  # Used to register your importer in the list of supported formats.
  # Normally you would not need to override this
  def self.inherited(by)
    Tracksperanto.importers << by
    super
  end
  
  # Return an extension WITH DOT if this format has a typical extension that
  # you can detect (like ".nk" for Nuke)
  def self.distinct_file_ext
  end
  
  # Should return a human-readable (read: properly capitalized and with spaces) name of the
  # import format
  def self.human_name
    "Abstract import format"
  end
  
  # Returns a textual description of things to check when the user wants to import from this specific format
  def self.known_snags
  end
  
  # Return true from this method if your importer can deduce the comp size from the passed file
  def self.autodetects_size?
    false
  end
  
  # Call this method from the inside of your importer to tell what you are doing. 
  # This gets propagated to the caller automatically, or gets ignored if the caller did not request any progress reports
  def report_progress(message)
    @progress_block.call(message) if @progress_block
  end
  
  # The main method of the parser. Should
  # yield each Tracker that has been fully parsed. After calling this method the caller can ask for
  # width and height as well.
  def each
  end
end
