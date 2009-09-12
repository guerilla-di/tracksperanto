# The base pipeline is the whole process of track conversion from start to finish. The pipeline object organizes the import formats, scans them,
# applies the default middlewares and yields them for processing. Here's how a calling sequence for a pipeline looks like:
#
#   pipe = Tracksperanto::Pipeline::Base.new
#   pipe.progress_block = lambda{|percent, msg| puts("#{msg}..#{percent.to_i}%") }
#   
#   pipe.run(input_file, width, height, reader_klass) do | scaler, slipper, golden, reformat |
#     golden.enabled = false
#     reformat.width = 1024
#     reformat.width = 576
#   end
#
# The pipeline will also automatically allocate output files with the right extensions at the same place where the original file resides,
# and setup outputs for all supported export formats. The pipeline will also report progress (with percent) using the passed progress block
class Tracksperanto::Pipeline::Base
  
  # How many points have been converted. In general, the pipeline does not preserve the parsed tracker objects
  # after they have been exported
  attr_accessor :converted_points
  
  # How many keyframes have been converted
  attr_accessor :converted_keyframes
  
  # A block acepting percent and message vars can be assigned here.
  # When it's assigned, the pipeline will pass the status reports
  # of all the importers and exporters to the block
  attr_accessor :progress_block
  
  # Runs the whole pipeline. Must receive the class used for parsing as the last argument
  def run(from_input_file_path, pix_w, pix_h, parser_class)
    # Grab the input
    read_data = File.open(from_input_file_path)
    
    # Assign the parser
    parser = parser_class.new(:width => pix_w, :height => pix_h)
    
    # Setup a multiplexer
    mux = setup_outputs_for(from_input_file_path)
    
    # Setup middlewares
    wrapper = setup_middleware_chain_with(mux)
    
    # Yield middlewares to the block
    yield(scaler, slipper, golden, reformat) if block_given?
    
    @converted_points, @converted_keyframes = run_export(read_data, parser, reformat) do | p, m |
      @progress_block.call(p, m) if @progress_block
    end
  end
  
  # Runs the export and returns the number of points and keyframes processed.
  # If a block is passed, the block will receive the percent complete and the last
  # status message that you can pass back to the UI
  def run_export(tracker_data_io, parser, processor)
    points, keyframes, percent_complete = 0, 0, 0.0
    
    yield(percent_complete, "Starting the parser") if block_given?
    parser.progress_block = lambda do | message |
      yield(percent_complete, message) if block_given?
    end
    
    trackers = parser.parse(tracker_data_io)
    
    validate_trackers!(trackers)
    
    yield(percent_complete = 50.0, "Parsing complete, starting export for #{trackers.length} trackers") if block_given?
    
    percent_per_tracker = (100.0 - percent_complete) / trackers.length
    
    # Use the width and height provided by the parser itself
    processor.start_export(parser.width, parser.height)
    
    yield(percent_complete, "Starting export") if block_given?
    
    trackers.each do | t |
      kf_weight = percent_per_tracker / t.keyframes.length
      points += 1
      processor.start_tracker_segment(t.name)
      t.keyframes.each do | kf |
        keyframes += 1
        processor.export_point(kf.frame, kf.abs_x, kf.abs_y, kf.residual)
        yield(percent_complete += kf_weight, "Writing keyframe") if block_given?
      end
      processor.end_tracker_segment
    end
    processor.end_export
    
    yield(100.0, "Wrote #{points} points and #{keyframes} keyframes") if block_given?
    
    [points, keyframes]
  ensure
    @ios.reject!{|e| e.close } if @ios
  end
  
  # Setup output files and return a single output
  # that replays to all of them
  def setup_outputs_for(input_file_path)
    file_name = File.basename(input_file_path).gsub(/\.([^\.]+)$/, '')
    Tracksperanto::Export::Mux.new(
      Tracksperanto.exporters.map do | exporter_class |
        export_name = "%s_%s" % [file_name, exporter_class.desc_and_extension]
        export_path = File.dirname(input_file_path) + '/' + export_name
        exporter = exporter_class.new(open_owned_export_file(export_path))
      end
    )
  end
  
  # Setup and return the output multiplexor wrapped in all necessary middlewares
  def setup_middleware_chain_with(output)
    scaler = Tracksperanto::Middleware::Scaler.new(output)
    slipper = Tracksperanto::Middleware::Slipper.new(scaler)
    golden = Tracksperanto::Middleware::Golden.new(slipper)
    Tracksperanto::Middleware::Reformat.new(golden)
  end
  
  # Open the file for writing and register it to be closed automatically
  def open_owned_export_file(path_to_file)
    @ios ||= []
    handle = File.open(path_to_file, "w")
    @ios << handle
    handle
  end
  
  # Check that the trackers made by the parser are A-OK
  def validate_trackers!(trackers)
    raise "Could not recover any trackers from this file. Wrong import format maybe?" if trackers.empty?
    trackers.each do | t |
      raise "Tracker #{t.name} had no keyframes" if t.keyframes.empty?
    end
  end
end