# This tool prepends the names of the trackers passing through it with a prefix
# and an underscore
class Tracksperanto::Tool::Prefix < Tracksperanto::Tool::Base
  
  parameter :prefix,  :cast => :string, :desc => "The prefix to apply", :default => "trk_"
  
  def self.action_description
    "Prefix tracker names with text"
  end
  
  def start_tracker_segment(tracker_name)
    prefixed_name = [prefix.gsub(/_$/, ''), tracker_name]
    prefixed_name.reject!{|e| e.empty? }
    super(prefixed_name.join('_'))
  end
  
end
