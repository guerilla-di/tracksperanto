require "forwardable"

# The base tool class works just like a Tracksperanto::Export::Base, but it only wraps another exporting object and does not get registered on it's own
# as an export format. Tool can be used to massage the tracks being exported in various interesting ways - like moving the coordinates, clipping the keyframes,
# scaling the whole export or even reversing the trackers to go backwards
class Tracksperanto::Tool::Base
  include Tracksperanto::Casts
  include Tracksperanto::BlockInit
  include Tracksperanto::ConstName
  include Tracksperanto::SimpleExport
  include Tracksperanto::Parameters
  
  extend Forwardable
  def_delegators :@exporter, :start_export, :start_tracker_segment, :end_tracker_segment, :export_point, :end_export
  
  # Used to automatically register your tool in Tracksperanto.tools
  # Normally you wouldn't need to override this
  def self.inherited(by)
    Tracksperanto.tools.push(by)
    super
  end
  
  # Returns the human name of the action that the tool will perform. The action is
  # the in infinitive form, like "Remove all the invalid keyframes", "Crop the image" and so on
  def self.action_description
    "Base tool class"
  end
  
  # Constructor accepts the exporter that will be wrapped, followed by the optional options hash
  # and the optional block that yields self
  def initialize(*exporter_and_args_for_block_init)
    @exporter = exporter_and_args_for_block_init.shift
    super
  end
end
