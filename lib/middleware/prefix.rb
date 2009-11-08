# This middleware prepends the names of the trackers passing through it with a prefix
# and an underscore
class Tracksperanto::Middleware::Prefix < Tracksperanto::Middleware::Base
  attr_accessor :prefix
  cast_to_string :prefix
  
  def start_tracker_segment(tracker_name)
    prefixed_name = [prefix.gsub(/_$/, ''), tracker_name]
    prefixed_name.reject!{|e| e.empty? }
    super(prefixed_name.join('_'))
  end
  
end