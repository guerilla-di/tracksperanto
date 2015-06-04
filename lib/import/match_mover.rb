# -*- encoding : utf-8 -*-
class Tracksperanto::Import::MatchMover < Tracksperanto::Import::Base
  
  def self.autodetects_size?
    true
  end
  
  def self.human_name
    "MatchMover REALVIZ Ascii Point Tracks .rz2 file"
  end
  
  def self.distinct_file_ext
    ".rz2"
  end
  
  def each
    detect_format(@io)
    raise "No tracker data after detecting format" if @io.eof?
    extract_trackers(@io) { |t| yield(t) }
  end
  
  private
  
  def detect_format(io)
    report_progress("Detecting width and height")
    lines = (0..2).map{ io.gets }
    last_line = lines[-1]
    int_groups = last_line.scan(/(\d+)/).flatten.map{|e| e.to_i }
    @width, @height = int_groups.shift, int_groups.shift
    unless @width && @height
      raise "Cannot detect the dimensions of the comp from the file"
    end
    
    # Next the starting frame of the sequence. The preamble ends with the p(0 293 1)
    # which is p( first_frame length framestep ). Some files export the path to the sequence
    # as multiline, so we will need to succesively scan until we find our line that contains the dimensions
    frame_steps_re = /b\( (\d+) (\d+) (\d+) \)/ # b( 0 293 1 )
    until @first_frame_of_sequence
      # There was nothing fetched, so we just assume the first frame is 0.
      # Or this line contained "}" which terminates the imageSequence block.
      if last_line.nil? || last_line.include?('}')
        @first_frame_of_sequence = 0
        return
      end
      
      digit_groups = last_line.scan(frame_steps_re).flatten
      if digit_groups.any?
        @first_frame_of_sequence, length, frame_step = digit_groups.map{|e| e.to_i }
        return
      end
      last_line = io.gets
    end
    raise "Cannot detect the start frame of the sequence"
  end
  
  def extract_trackers(io)
    while(line = io.gets) do
      yield(extract_track(line, io)) if line =~ /^pointTrack/
    end
  end
  
  def extract_track(start_line, io)
    tracker_name = start_line.scan(/\"([^\"]+)\"/).flatten[0]
    report_progress("Extracting tracker #{tracker_name}")
    t = Tracksperanto::Tracker.new(:name => tracker_name)
    while(line = io.gets) do
      return t if line =~ /\}/
      t.push(extract_key(line.strip)) if line =~ /^(\s+?)(\d)/
      report_progress("Extracting keyframe")
    end
    raise "Track didn't close"
  end
  
  FLOAT_PATTERN = /[\-\d\.]+/
  LINE_PATTERN = /(\d+)\s+(#{FLOAT_PATTERN})\s+(#{FLOAT_PATTERN})/
  
  def extract_key(line)
    frame, x, y = line.scan(LINE_PATTERN).flatten
    Tracksperanto::Keyframe.new(
      :frame => (frame.to_i - @first_frame_of_sequence),
      :abs_x => x,
      :abs_y => @height - y.to_f, # Top-left in MM
      :residual => extract_residual(line)
    )
  end
  
  RESIDUAL_SEGMENT = /p[\*\+]\(\s+?(#{FLOAT_PATTERN})\s+?\)/
  
  def extract_residual(line)
    if line =~ RESIDUAL_SEGMENT
      1- $1.to_f
    else
      0
    end
  end
end
