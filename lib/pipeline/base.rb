# This is currently a bit of a mess.
module Tracksperanto::Pipeline
class Base
  attr_accessor :converted_points
  attr_accessor :converted_keyframes
  attr_accessor :progress_block
  
  def run(from_input_file_path, pix_w, pix_h, parser_class)
    # Read the input file
    read_data = File.read(from_input_file_path)
    
    # Assign the parser
    parser = create_parser(parser_class, pix_w, pix_h)
    
    # Setup a multiplexer
    mux = setup_outputs_for(from_input_file_path)
    
    # Setup middlewares - skip for now
    scaler = Tracksperanto::Middleware::Scaler.new(mux)
    slipper = Tracksperanto::Middleware::Slipper.new(scaler)
    golden = Tracksperanto::Middleware::Golden.new(slipper)
    reformat = Tracksperanto::Middleware::Reformat.new(golden)
    
    # Yield middlewares to the block
    yield(scaler, slipper, golden, reformat) if block_given?
    
    @converted_points, @converted_keyframes = run_export(read_data, parser, reformat) do | p, m |
      @progress_block.call(p, m) if @progress_block
    end
  end
  
  # Runs the export and returns the number of points and keyframes processed.
  # If a block is passed, the block will receive the percent complete and the last
  # status message that you can pass back to the UI
  # # :yields: percent_complete, status_message
  def run_export(tracker_data_blob, parser, processor)
    points, keyframes, percent_complete = 0, 0, 0.0
    
    yield(percent_complete, "Starting the parse routine") if block_given?
    parser.progress_block = lambda do | message |
      yield(percent_complete, message) if block_given?
    end
    
    trackers = parser.parse(tracker_data_blob)
    
    yield(percent_complete = 20.0, "Starting export for #{trackers.length} trackers") if block_given?
    
    percent_per_tracker = 80.0 / trackers.length
    
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
  end
  
  def create_parser(parser_class, w, h)
    p = parser_class.new
    p.width, p.height = w, h
    p
  end
  
  def setup_outputs_for(input_file_path)
    file_name = File.basename(input_file_path).gsub(/\.([^\.]+)$/, '')
    Tracksperanto::Export::Mux.new(
      Tracksperanto.exporters.map do | exporter_class |
        export_name = "%s_%s" % [file_name, exporter_class.desc_and_extension]
        export_path = File.dirname(input_file_path) + '/' + export_name
        exporter = exporter_class.new(File.open(export_path, 'w'))
        Tracksperanto::Middleware::Close.new(exporter)
      end
    )
  end
end
end