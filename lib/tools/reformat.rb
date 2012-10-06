# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/scaler'

# This tool reformats (scales) the track setup to a specific pixel resolution. Very useful for
# applying proxy tracks to full-res images
class Tracksperanto::Tool::Reformat < Tracksperanto::Tool::Base
  
  parameter :width,  :cast => :int, :desc => "New comp width in px", :default => 1080
  parameter :height,  :cast => :int, :desc => "New comp height in px", :default => 1080
  
  def self.action_description
    "Reformat the comp together with it's trackers to conform to a specific format"
  end
  
  # Called on export start
  def start_export( img_width, img_height)
    @width ||= img_width # If they be nil
    @height ||= img_height
    
    x_factor, y_factor = (@width / img_width.to_f), (@height / img_height.to_f)  
    
    @stash = @exporter
    @exporter = Tracksperanto::Tool::Scaler.new(@exporter, :x_factor => x_factor, :y_factor => y_factor)
    super
  end
end
