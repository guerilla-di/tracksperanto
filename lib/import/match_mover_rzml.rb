require "rexml/document"

class Tracksperanto::Import::MatchMoverRZML < Tracksperanto::Import::Base
  
  def self.autodetects_size?
    true
  end
  
  def self.human_name
    "MatchMover RZML .rzml file"
  end
  
  def self.distinct_file_ext
    ".rzml"
  end
  
  class Listener
    
    def initialize(from_parser, tracker_callback)
      @cb = tracker_callback
      @path = []
      @parser = from_parser
      @trackers = []
    end
    
    def depth
      @path.length
    end
    
    def tag_start(element_name, attrs)
      @path << element_name.downcase
      
      if element_name.downcase == 'shot'
        @parser.width = attrs["w"]
        @parser.height = attrs["h"]
      end
      
      return unless @path.include?("ipln")
      
      #  <IPLN img="/home/torsten/some_local_nuke_scripts/render_tmp/md_145_1070_right.####.jpg" b="1" e="71">
      #		<IFRM>
      #			<M i="1" k="i" x="626.68" y="488.56" tt="0.8000000119" cf="0">
      if element_name.downcase == 'm'
        @parser.report_progress "Adding tracker"
        @trackers.push(Tracksperanto::Tracker.new(:name => attrs["i"]))
      end
      
      if element_name.downcase == "ifrm" && attrs["t"]
        @frame = attrs["t"].to_i
      end
      
      if element_name.downcase == "m"
        target_marker = @trackers.find{|e| e.name == attrs["i"] }
        @parser.report_progress "Recovering keyframe at #{@frame}"
        target_marker.keyframe!(:frame => @frame, :abs_x => attrs["x"], :abs_y => (@parser.height - attrs["y"].to_f), :residual => attrs["tt"])
      end
    end
    
    def tag_end(element_name)
      @path.pop
      if element_name.downcase == "rzml"
        @trackers.reject!{|e| e.empty? }
        
        @trackers.each do | recovered_tracker |
          @parser.report_progress "Pushing tracker #{recovered_tracker.name.inspect}"
          @cb.call(recovered_tracker)
        end
      end
    end
    
    def in?(path_elems)
      File.join(@path).include?(path_elems)
    end
    
    def xmldecl(*a); end
    def text(t); end
  end
  
  def each
    cb = lambda{|e| yield(e) }
    REXML::Document.parse_stream(@io, Listener.new(self, cb))
  end
end
