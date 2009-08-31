# This is currently a bit of a mess.
module Tracksperanto::Pipeline
class Base
  attr_accessor :converted_points
  attr_accessor :converted_keyframes
  
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
    
    # Yield middlewares to the block
    yield(scaler, slipper, golden) if block_given?
    
    # Run the export
    @converted_points, @converted_keyframes = run_export(read_data, parser, golden)
  end
  
  # Runs the export and returns the number of points and keyframes processed
  def run_export(tracker_data_blob, parser, processor)
    points, keyframes = 0, 0
    
    trackers = parser.parse(tracker_data_blob)
    processor.start_export(parser.width, parser.height)
    trackers.each do | t |
      points += 1
      processor.start_tracker_segment(t.name)
      t.keyframes.each do | kf |
        keyframes += 1
        processor.export_point(kf.frame, kf.abs_x, kf.abs_y, kf.residual)
      end
    end
    processor.end_export
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