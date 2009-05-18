class Tracksperanto::Pipeline
  attr_accessor :converted_points
  attr_accessor :converted_keyframes
  def run(from_input_file, pix_w, pix_h, parser_class)
    # Read the input file
    read_data = File.read(from_input_file)
    file_name = File.basename(from_input_file).gsub(/\.([^\.]+)$/, '')
    
    # Assign the parser
    parser = parser_class.new
    parser.width = pix_w
    parser.height = pix_h
    
    # Setup a multiplexer
    mux = Tracksperanto::Export::Mux.new(
      Tracksperanto.exporters.map do | exporter_class |
        export_name = "%s_%s" % [file_name, exporter_class.desc_and_extension]
        outfile = File.dirname(from_input_file) + '/' + export_name
        io = File.open(outfile, 'w')
        exporter_class.new(io)
      end
    )
    
    # Setup middlewares - skip for now
    scaler = Tracksperanto::Middleware::Scaler.new(mux)
    slipper = Tracksperanto::Middleware::Slipper.new(scaler)
    golden = Tracksperanto::Middleware::Golden.new(slipper)
    
    yield(scaler, slipper, golden) if block_given?
    
    processor = golden
    
    # Run the export
    trackers = parser.parse(read_data)
    processor.start_export(parser.width, parser.height)
    trackers.each do | t |
      
      @converted_points ||= 0
      @converted_points += 1
      
      processor.start_tracker_segment(t.name)
      t.keyframes.each do | kf |
        
        @converted_keyframes ||= 0
        @converted_keyframes += 1
        
        processor.export_point(kf.frame, kf.abs_x, kf.abs_y, kf.residual)
      end
    end
    
    processor.end_export
  end
end
  