## Hacking Tracksperanto

### Tests

Tracksperanto is heavily tested. Please use the Github checkout to also receive some 17+ megabytes of test files that the test suite
can chew on. Contributions or patches without tests will be rejected at sight.

### Development environment

Tracksperanto is currently being developed on Ruby 1.9.3 but it should also work fine on 1.8.7.
What you will need is everything mentioned in the Gemfile plus Bundler.
Development should be done agains the git checkout because the gem does not contain the test files
(various example files in different formats that are used for verifying all the import and export modules).

The test corpus on Tracksperanto is HUGE at the moment, and it makes no sense to ship it with the gem.

So, to get started:

* Make sure you have Ruby and Bundler (`sudo gem install bundler` if unsure)
* Checkout the repo at http://github.com/guerilla-di/tracksperanto
* Run `bundle install` and `bundle exec rake` to run the tests
* Do your thing, in a separate branch
* File a pull request or send a patch to **me at julik dot nl**

### Internal tracker representation

The trackers are represented by Tracker objects, which work like addressable hashes per frame number. The Tracker objects
contain Keyframe objects, and those in turn contain coordinates. The coordinates are stored in absolute pixels, relative to
the zero coordinate in the lower left corner.

Note on subpixel precision: the absolute left/bottom of the image has coordinates 0,0 
(at the lower left corner of the leftmost bottommost pixel) and 0.5x0.5 in the middle of that pixel.

### Importing your own formats

To write an import module refer to Tracksperanto::Import::Base
docs. Your importer will be configured with width and height of the comp that it is importing, and will get an IO 
object with the file that you are processing. You should then yield parsed trackers within the each method (tracker objects should
be Tracksperanto::Tracker objects or compatibles)

### Exporting your own formats

You can easily write an exporter. Refer to the Tracksperanto::Export::Base docs. Note that your exporter should be able to chew alot of data
(hundreds of trackers with thousands of keyframes with exported files growing up to 5-10 megs in size are not uncommon!). This means that
the exporter should work with streams (smaller parts of the file being exported will be held in memory at a time).

### Ading your own processing steps

You probably want to write a Tool (consult the Tracksperanto::Tool::Base docs) if you need some processing applied to the tracks
or their data. A Tool is just like an export module, except that instead it sits between the exporter and the exporting routine. Tools wrap export
modules or each other, so you can stack different tool modules together (like "scale first, then move").

### Writing your own processing pipelines from start to finish

You probably want to write a descendant of Tracksperanto::Pipeline::Base. This is a class that manages a conversion from start to finish, including detecting the
input format, allocating output files and building a chain of Tools to process the export. If you want to make a GUI for Tracksperanto you will likely need
to write your own Pipeline class or reimplement parts of it.

### Reporting status from long-running operations

Almost every module in Tracksperanto has a method called report_progress. This method is used to notify an external callback of what you are doing, and helps keep
the software user-friendly. A well-behaved Tracksperanto module should manage it's progress reports properly.

### Sample script

    require "rubygems"
    require "tracksperanto"
    
    include Tracksperanto
    
    # Create the importer object, for example for a Shake script.
    # get_importer will give you the good class even you get the capitalization
    # wrong!
    some_importer = Tracksperanto.get_importer("shakescript").new
    
    # This importer needs to know width and height
    some_importer.width = 1024
    some_importer.height = 576
    some_importer.io = File.open("source_file.shk")
    
    # The importer responds to each() so if your file is not too big you can just load all the trackers
    # as an array. If you expect to have alot of trackers investigate a way to buffer them on disk
    # instead (see Obuf)
    trackers = some_importer.to_a
    
    # Create the exporter and pass the output file to it
    destination_file = File.open("exported_file.other", "wb")
    some_exporter = Tracksperanto.get_exporter("flamestabilizer").new(destination_file)
    
    # Now add some tools, for example a Scale
    scaler = Tool::Scaler.new(some_exporter, :x_factor => 2)
    # ... and a slip. Tools wrap exporters and other tools, so you can chain them
    # ad nauseam
    slipper = Tool::Slipper.new(scaler, :offset => 2)
    
    # Now when we send export commands to the Slipper it will play them through
    # to the Scaler and the Scaler in turn will send commands to the exporter.
    # As you can see when you run export commands you do not have to use the Tracker
    # objects, you just have to stream the right arguments in the right sequence
    slipper.start_export(1024, 576)
    trackers.each do | t |
      slipper.start_tracker_segment(t.name)
      t.each do | keyframe |
        slipper.export_point(keyframe.frame, keyframe.abs_x, keyframe.abs_y, keyframe.residual)
      end
      slipper.end_tracker_segment
    end
    slipper.end_export
    
    # And we are done!
    