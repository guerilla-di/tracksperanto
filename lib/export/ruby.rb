# Exports the trackers to a script that is fit for massaging with Tracksperanto as is
class Tracksperanto::Export::Ruby < Tracksperanto::Export::Base
  
  def self.desc_and_extension
    "tracksperanto_ruby.rb"
  end
  
  def self.human_name
    "Bare Ruby code"
  end
  
  def start_export(w,h)
    @io.puts "require 'rubygems'"
    @io.puts "require 'tracksperanto'"
    @io.puts("width = %d" % w)
    @io.puts("height = %d" % h)
    @io.puts("trackers = []")
  end
  
  def start_tracker_segment(name)
    @io.puts(" ")
    @io.write("trackers << ")
    @tracker = Tracksperanto::Tracker.new(:name => name)
  end
  
  def export_point(f, x, y, r)
    @tracker.keyframe! :frame => f, :abs_x => x, :abs_y => y, :residual => r
  end
  
  def end_tracker_segment
    @io.puts(@tracker.to_ruby)# Just leave that
  end
  
  def end_export
    @io.puts(" ")
  end
end
