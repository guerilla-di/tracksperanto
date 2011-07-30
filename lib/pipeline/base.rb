module Tracksperanto::Pipeline

  class EmptySourceFileError < RuntimeError
    def message;  "This is an empty source file"; end
  end
  
  class UnknownFormatError < RuntimeError
    def message; "Unknown input format"; end
  end
  
  class DimensionsRequiredError < RuntimeError
    def message; "Width and height must be provided for this importer"; end
  end
  
  class NoTrackersRecoveredError < RuntimeError
    def message; 
      "Could not recover any non-empty trackers from this file.\n" + 
      "Wrong import format maybe?\n" + 
      "Note that PFTrack will only export trackers from the solved segment of the shot.";
    end
  end
  
  # The base pipeline is the whole process of track conversion from start to finish. The pipeline object organizes the import formats, scans them,
  # applies the middlewares. Here's how a calling sequence for a pipeline looks like:
  #
  #   pipe = Tracksperanto::Pipeline::Base.new
  #   pipe.middleware_tuples = ["Golden", {:enabled => true}]
  #   pipe.progress_block = lambda{|percent, msg| puts("#{msg}..#{percent.to_i}%") }
  #   pipe.run("/tmp/shakescript.shk", :width => 720, :height => 576)
  #
  # The pipeline will also automatically allocate output files with the right extensions
  # at the same place where the original file resides,
  # and setup outputs for all supported export formats.
  class Base
  
  EXTENSION = /\.([^\.]+)$/ #:nodoc:
  PERMITTED_OPTIONS = [:importer, :width, :height]
  
  include Tracksperanto::BlockInit
  
  # How many points have been converted. In general, the pipeline does not preserve the parsed tracker objects
  # after they have been exported
  attr_reader :converted_points
  
  # How many keyframes have been converted
  attr_reader :converted_keyframes
  
  # A block acepting percent and message vars can be assigned here.
  # When it's assigned, the pipeline will pass the status reports
  # of all the importers and exporters to the block, together with
  # percent complete
  attr_accessor :progress_block
  
  # Assign an array of exporters to use them instead of the standard ones 
  attr_accessor :exporters
  
  # Contains arrays of the form ["MiddewareName", {:param => value}]
  attr_accessor :middleware_tuples
  
  
  def initialize(*any)
    super
    @ios = []
  end
  
  def wrap_output_with_middlewares(output)
    return output unless (middleware_tuples && middleware_tuples.any?)
    
    middleware_tuples.reverse.inject(output) do | wrapped, (middleware_name, options) |
      Tracksperanto.get_middleware(middleware_name).new(wrapped, options || {})
    end
  end
  
  # Runs the whole pipeline. Accepts the following options
  # * width - The comp width, for the case that the format does not support auto size
  # * height - The comp height, for the case that the format does not support auto size
  # * parser - The parser class, for the case that it can't be autodetected from the file name
  def run(from_input_file_path, passed_options = {}) #:yields: *all_middlewares
    
    # Check for empty files
    raise EmptySourceFileError if File.stat(from_input_file_path).size.zero?
    
    # Reset stats
    @converted_keyframes, @converted_points = 0, 0
    
    # Assign the parser
    importer = initialize_importer_with_path_and_options(from_input_file_path, passed_options)
    
    # Open the file
    read_data = File.open(from_input_file_path, "rb")
        
    # Setup a multiplexer
    mux = setup_outputs_for(from_input_file_path)
    
    # Wrap it into a module that will prevent us from exporting invalid trackers
    lint = Tracksperanto::Middleware::Lint.new(mux)
    
    # Setup middlewares
    endpoint = wrap_output_with_middlewares(lint)
    @converted_points, @converted_keyframes = run_export(read_data, importer, endpoint)
  end
  
  def report_progress(percent_complete, message)
    int_pct = percent_complete.to_f.floor # Prevent float overflow above 100 percent
    @progress_block.call(int_pct, message) if @progress_block
  end
  
  def initialize_importer_with_path_and_options(from_input_file_path, options)
    
    d = Tracksperanto::FormatDetector.new(from_input_file_path)
    
    if options[:importer]
      imp = Tracksperanto.get_importer(options[:importer])
      require_dimensions_in!(options) unless imp.autodetects_size?
      imp.new(:width => options[:width], :height => options[:height])
    elsif d.match? && d.auto_size?
      d.importer_klass.new
    elsif d.match?
      require_dimensions_in!(options)
      d.importer_klass.new(:width => options[:width], :height => options[:height])
    else
      raise UnknownFormatError
    end
  end
  
  def require_dimensions_in!(opts)
    raise DimensionsRequiredError unless (opts[:width] && opts[:height])
  end
  
  # Runs the export and returns the number of points and keyframes processed.
  # If a block is passed, the block will receive the percent complete and the last
  # status message that you can pass back to the UI
  def run_export(tracker_data_io, importer, exporter)
    points, keyframes, percent_complete = 0, 0, 0.0
    last_reported_percentage = 0.0
    
    report_progress(percent_complete, "Starting the parser")
    progress_lambda = lambda do | m | 
      last_reported_percentage = percent_complete
      report_progress(percent_complete, m)
    end
    
    # Report progress from the parser
    importer.progress_block = progress_lambda
    
    # Wrap the input in a progressive IO, setup a lambda that will spy on the reader and 
    # update the percentage. We will only broadcast messages that come from the parser 
    # though (complementing it with a percentage)
    io_with_progress = Tracksperanto::ProgressiveIO.new(tracker_data_io) do | offset, of_total |
      percent_complete = (50.0 / of_total) * offset
      
      # Some importers do not signal where they are and do not send nice reports. The way we can help that in the interim
      # would be just to indicate where we are in the input, but outside of the exporter. We do not want to flood
      # the logs though so what we WILL do instead is report some progress going on every 2-3 percent
      progress_lambda.call("Parsing the file") if (percent_complete - last_reported_percentage) > 3
    end
    
    @ios.push(io_with_progress)
    
    @accumulator = Tracksperanto::Accumulator.new
    
    begin
    
      # OBSOLETE - for this version we are going to permit it.
      if importer.respond_to?(:stream_parse)
        STDERR.puts "Import::Base#stream_parse(io) is obsolete, please rewrite your importer to use each instead"
        importer.receiver = @accumulator
        importer.stream_parse(io_with_progress)
      else
        importer.io = io_with_progress
        importer.each {|t| @accumulator.push(t) unless t.empty? }
      end
    
      report_progress(percent_complete = 50.0, "Validating #{@accumulator.size} imported trackers")
      raise NoTrackersRecoveredError if @accumulator.size.zero?
    
      report_progress(percent_complete, "Starting export")
    
      percent_per_tracker = (100.0 - percent_complete) / @accumulator.size
    
      # Use the width and height provided by the parser itself
      exporter.start_export(importer.width, importer.height)
    
      # Now send each tracker through the middleware chain
      @accumulator.each_with_index do | t, tracker_idx |
      
        kf_weight = percent_per_tracker / t.keyframes.length
        points += 1
        exporter.start_tracker_segment(t.name)
        t.each_with_index do | kf, idx |
          keyframes += 1
          exporter.export_point(kf.frame, kf.abs_x, kf.abs_y, kf.residual)
          report_progress(
              percent_complete += kf_weight,
              "Writing keyframe #{idx+1} of #{t.name.inspect}, #{@accumulator.size - tracker_idx} trackers to go"
          )
        end
        exporter.end_tracker_segment
      end
      exporter.end_export
    
      report_progress(100.0, "Wrote #{points} points and #{keyframes} keyframes")
    
      [points, keyframes]
    ensure
      @accumulator.clear
      @ios.map!{|e| e.close! rescue e.close }
      @ios.clear
    end
  end
  
  # Setup output files and return a single output
  # that replays to all of them
  def setup_outputs_for(input_file_path)
    file_name = File.basename(input_file_path).gsub(EXTENSION, '')
    outputs = (exporters || Tracksperanto.exporters).map do | exporter_class |
      export_name = [file_name, exporter_class.desc_and_extension].join("_")
      export_path = File.join(File.dirname(input_file_path), export_name)
      exporter_class.new(open_owned_export_file(export_path))
    end
    
    Tracksperanto::Export::Mux.new(outputs)
  end
  
  # Open the file for writing and register it to be closed automatically
  def open_owned_export_file(path_to_file)
    @ios.push(File.open(path_to_file, "wb"))[-1]
  end
end
end