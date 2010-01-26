# The base pipeline is the whole process of track conversion from start to finish. The pipeline object organizes the import formats, scans them,
# applies the default middlewares and yields them for processing. Here's how a calling sequence for a pipeline looks like:
#
#   pipe = Tracksperanto::Pipeline::Base.new
#   pipe.progress_block = lambda{|percent, msg| puts("#{msg}..#{percent.to_i}%") }
#   
#   pipe.run("/tmp/shakescript.shk", :pix_w => 720, :pix_h => 576) do | *all_middlewares |
#     # configure middlewares here
#   end
#
# The pipeline will also automatically allocate output files with the right extensions
# at the same place where the original file resides,
# and setup outputs for all supported export formats.
class Tracksperanto::Pipeline::Base
  
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
  
  DEFAULT_OPTIONS = {:pix_w => 720, :pix_h => 576, :parser => Tracksperanto::Import::ShakeScript }
  
  # Runs the whole pipeline. Accepts the following options
  # * pix_w - The comp width, for the case that the format does not support auto size
  # * pix_h - The comp height, for the case that the format does not support auto size
  # * parser - The parser class, for the case that it can't be autodetected from the file name
  def run(from_input_file_path, passed_options = {}) #:yields: *all_middlewares
    o = DEFAULT_OPTIONS.merge(passed_options)
    pix_w, pix_h, parser_class = detect_importer_or_use_options(from_input_file_path, o)
    
    # Reset stats
    @converted_keyframes, @converted_points = 0, 0
    
    # Grab the input
    read_data = File.open(from_input_file_path, "rb")
    
    # Assign the parser
    importer = parser_class.new(:width => pix_w, :height => pix_h)
    
    # Setup a multiplexer
    mux = setup_outputs_for(from_input_file_path)
    
    # Setup middlewares
    middlewares = setup_middleware_chain_with(mux)
    
    # Yield middlewares to the block
    yield(*middlewares) if block_given?
    
    @converted_points, @converted_keyframes = run_export(read_data, importer, middlewares[-1]) do | p, m |
      @progress_block.call(p, m) if @progress_block
    end
  end
  
  def detect_importer_or_use_options(path, opts)
    d = Tracksperanto::FormatDetector.new(path)
    if d.match? && d.auto_size?
      return [1, 1, d.importer_klass]
    elsif d.match?
      raise "Width and height must be provided for a #{d.importer_klass}" unless (opts[:pix_w] && opts[:pix_h])
      opts[:parser] = d.importer_klass
    else
      raise "Cannot autodetect the file format - please specify the importer explicitly" unless opts[:parser]
      unless opts[:parser].autodetects_size?
        raise "Width and height must be provided for this importer" unless (opts[:pix_w] && opts[:pix_h])
      end
    end
    
    [opts[:pix_w], opts[:pix_h], opts[:parser]]    
  end
  
  # Runs the export and returns the number of points and keyframes processed.
  # If a block is passed, the block will receive the percent complete and the last
  # status message that you can pass back to the UI
  def run_export(tracker_data_io, parser, processor)
    @ios << tracker_data_io
    
    points, keyframes, percent_complete = 0, 0, 0.0
    
    yield(percent_complete, "Starting the parser") if block_given?
    parser.progress_block = lambda do | message |
      yield(percent_complete, message) if block_given?
    end
    
    trackers = parser.parse(tracker_data_io)
    
    validate_trackers!(trackers)
    
    yield(percent_complete = 50.0, "Parsing complete, starting export for #{trackers.length} trackers") if block_given?
    
    percent_per_tracker = (100.0 - percent_complete) / trackers.length
    
    yield(percent_complete, "Starting export") if block_given?
    
    # Use the width and height provided by the parser itself
    processor.start_export(parser.width, parser.height)
    trackers.each do | t |
      kf_weight = percent_per_tracker / t.keyframes.length
      points += 1
      processor.start_tracker_segment(t.name)
      t.each_with_index do | kf, idx |
        keyframes += 1
        processor.export_point(kf.frame, kf.abs_x, kf.abs_y, kf.residual)
        yield(percent_complete += kf_weight, "Writing keyframe #{idx+1} of #{t.name.inspect}") if block_given?
      end
      processor.end_tracker_segment
    end
    processor.end_export
    
    yield(100.0, "Wrote #{points} points and #{keyframes} keyframes") if block_given?
    
    [points, keyframes]
  ensure
    @ios.reject!{|e| e.close unless (!e.respond_to?(:closed?) || e.closed?) } if @ios
  end
  
  # Setup output files and return a single output
  # that replays to all of them
  def setup_outputs_for(input_file_path)
    file_name = File.basename(input_file_path).gsub(/\.([^\.]+)$/, '')
    export_klasses = exporters || Tracksperanto.exporters    
    Tracksperanto::Export::Mux.new(
      export_klasses.map do | exporter_class |
        export_name = [file_name, exporter_class.desc_and_extension].join("_")
        export_path = File.join(File.dirname(input_file_path), export_name)
        exporter = exporter_class.new(open_owned_export_file(export_path))
      end
    )
  end
  
  # Setup and return the output multiplexor wrapped in all necessary middlewares.
  # Middlewares must be returned in an array to be passed to the configuration block
  # afterwards
  def setup_middleware_chain_with(output)
    scaler = Tracksperanto::Middleware::Scaler.new(output)
    slipper = Tracksperanto::Middleware::Slipper.new(scaler)
    golden = Tracksperanto::Middleware::Golden.new(slipper)
    reformat = Tracksperanto::Middleware::Reformat.new(golden)
    shift = Tracksperanto::Middleware::Shift.new(reformat)
    prefix = Tracksperanto::Middleware::Prefix.new(shift)
    [scaler, slipper, golden, reformat, shift, prefix]
  end
  
  # Open the file for writing and register it to be closed automatically
  def open_owned_export_file(path_to_file)
    @ios ||= []
    handle = File.open(path_to_file, "wb")
    @ios << handle
    handle
  end
  
  # Check that the trackers made by the parser are A-OK
  def validate_trackers!(trackers)
    trackers.reject!{|t| t.length < 2 }
    raise "Could not recover any non-empty trackers from this file. Wrong import format maybe?" if trackers.empty?
  end
end