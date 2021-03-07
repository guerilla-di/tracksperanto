### 4.2.0

* Revert keyword arguments change in BlockInit so that compatibility with Ruby 3.x can be assured

### 4.1.3

* Make sure the test corpus doesn't get included in the released gem (size constraints)

### 4.1.2

* Update the used version of Tickly (used for Nuke scripts)

### 4.1.0

* Iron out a few kinks with the now-smaller subset of Rubies we support

### 4.0.0

* The version drop support for Ruby versions below 2.2 - older versions of Tracksperanto still can be installed and used, but not 4.x and newer. We need to make this change to simplify CI runs and the test matrix, also installing and running older Ruby versions is turning into more and more of a hassle
* Update some idioms for more modern Ruby syntax: introduce `require_relative` in most places, use `#tap` instead of `#returning` and other small modernizations
* Remove Jeweler which was used for packaging the gem and use just builtin Bundler features + .gemspec file

### 3.5.9

* Set the maximum version for some gems to reenable Ruby 1.8.7 installs

### 3.5.8

* Fixes to MatchMover .rz import

### 3.5.6

* SynthEyes has two export formats which creates confusion. Add snag messages to import moudules to hint that.

### 3.5.5

* Fix joining animation curves that had negative frame numbers (might happen in Nuke scripts)

### 3.5.4

* Fix parsing Nuke scripts with Tracker4 where some tracks were expression-only
* Fix parsing Nuke scripts with Tracker4 nodes having empty or no tracks at all

### 3.5.0

* Add early bailout if unsupported formats are fed in. Because some people just can't read.

### 3.4.1

* Fix parsing of curve expressions with modifiers in Nuke scripts

### 3.4.0

* Add specific Flame/Smoke exporters for IFFS 2014 and above, including updated cornerpin order

### 3.3.13

* Fix the bug in Shake script imports where the import would fail if animation curves contained a non-numeric value

### 3.3.12

* Fix the bug in MatchMover imports that caused the import to fail if the file contained a multiline path

### 3.3.11

* Fix the bug that caused CLI short flags to be ignored

### 3.3.10

* Use the updated Tickly for Nuke's animation curves that have a slightly different format

### 3.3.9

* Use the updated Tickly that handles Winshitows line breaks gracefully

### 3.3.8

* Small bugfix in the Nuke import module
* Add Nuke Transform2D support for center and translate

### 3.3.7

* Fix PlanarTracker import support in Nuke 7 scripts
* Add Nuke CornerPin node support

### 3.3.6

* Shake out the latest Bundler integration issues

### 3.3.0

* Require dependencies using Bundler
* Update to newer Tickly that has a faster parser

### 3.2.2

* Bump a whole array of dependencies to speed up and simplify Nuke and Shake parsers

### 3.2.1

* Improve Nuke 7 import support with the new version of Tickly

### 3.2.0

* Add Nuke 7 import support

### 3.1.0

* Add a Maxscript export module

### 3.0.1

* Subtract 1 frame from PFTrack imports (PFTrack starts on 1)

### 3.0.0

* Middleware renamed to Tools
* Multiple subpixel accuracy tests added
* Subpixel accuracy fixed for Syntheyes modules
* Subpixel accuracy fixed for PFTrack modules

### 2.12.0

* Add an export module for Nuke's CameraTracker node. This is just like the Shake format, except that tracker names have to be special.

### 2.11.3

* Hint that we only support specific nodes in Nuke
* Hint the user that a comp must be focused in AfterEffects when the import script is run without focusing on a comp first

### 2.11.1

* Fixes a bug with importer snag display

### 2.11.0

* This release adds a Softimage|XSI export module which outputs a Python script with moving nulls on an image plane

### 2.10.0

* Nuke importer now supports PlanarTracker nodes and their corner-pin output

### 2.9.9

* Add lens distortion tool. Adds the possibility to remove or add Syntheyes lens distortion to your plates.

### 2.9.8

* Ensure that Boujou vertical coords start off 1, not off 0 - both in import and export

### 2.9.7

* Add Syntheyes "All tracker paths" support

### 2.9.6

* Add Nuke Reconcile3D support
* Add Tool::Base.parameters for automatic GUI building

### 2.9.5

* Export a Maya ASCII scene instead of a MEL script

### 2.9.4

* Add MatchMover RZML import support
* Export Boujou trackers starting at frame 0, not at frame 1

### 2.9.3

* Add export for AE null layers as a .jsx script

### 2.9.2

* In the Maya locator export, do not advance the timebar when creating trackers. Refreshing all these viewports is SLOW.

### 2.9.1

* Adds an export module for Maya locators on an image plane

### 2.9

* Tracker objects now use a Hash as internal storage model instead of being an Array delegate.
  Note that due to that some stuff might have become broken since behavior differs in subtle ways.
* Adds a Ruby export format which exports a file you can play with in Ruby, with literal values
* Make test runs architecture-resilient by hardcoding floats
* Adds Tracker#to_ruby for people who like that sort of thing

### 2.8.6

* Ensure the Flame cornerpin export module always exports points in the proper Z-order

### 2.8.5

* Add Pad and Crop tools for fixing botched telecine and anamorphic Alexa

### 2.8.2

* Fix release gemspec

### 2.8.2

* Dramatically improve the update speed by not shipping the test cases with the gem anymore
* Fix obuf for ruby 1.8x

### 2.8.1

* Fix the bug that MatchMover importer would always assume the sequence starting on frame 1
* Fix the bug that Lint tool would raise when the export was started from negative frame offsets

### 2.8.0

* Add a special exporter for Flame cornerpins. Apparently the bilinear staiblizer wants the trackers to have the right names
  right from the start (top_left, top_right and so on)
* Check trackers sent through to ensure that they always come sequentially without violating the frame ordering

### 2.7.0

* Speedup Shake script parsing by using a buffering reader

### 2.6.4

* Use various external dependencies that we extracted
* Note that Nuke now supports import and export of camera tracker features!

### 2.6.3

* Report progress from the parser for Flame, like it has been before

### 2.6.2

* Fix missing progress percentages in the Flame import module

### 2.6.1

* Fix errors that occurred when empty disabled trackers were present in Flame setups 
* Give better error reports when an unknown constant gets requested (like a wrong importer)
* Use the flame_channel_parser gem now that it's stable.

### 2.6.0

* Adds the --trim option to remove keyframes that come in negative frames (before frame 0).
  Some apps improperly handle such frames (Syntheyes)

### 2.5.0

* No status display in the progress bar. It was an annoyance.
* There are still crashes with flexmocks in tests, relevant flexmock issues filed upstream
* Fix Ruby 1.9 compatibility (but the situation will get better since it's now the primary version)
* Use update_hints gem for version checks
* PFTrack 2011 and PFMAtchit actually use the same format, so we don't need to have 2 modules for them

### 2.4.0

* Added an official PFTrack 2011 exporter that is verified

### 2.3.3

* Fixed parsing of stereoscopic PFTrack exports

### 2.3.2

* Fixed handling of inline comments which are tacked onto the line in in Shake scripts

### 2.3.1

* Fixed support for curly braces in Shake scripts
* Added checks to prevent exports with empty trackers or exports which contain no data at all

### 2.3.0

* Fixed issue#1 (Last tracker in some Flame exports receives an empty shift channel)
* Nicer progress reports
* Modified the Accumulator to support nested iterations and random access

### 2.2.4

* Properly deal with negative frames happening in Shake scripts sometimes. We will now recognize a script starting at negative
frames and "bump" it's frames in curves so that everything neatly starts at frame 0. Granted this does not give us the same frame range
but most apps wil go bonkers anyway if we send them negative frame numbers.

### 2.2.3

* Prevent zero-length trackers (trackers having no position information) from being accumulated during import.
This had adverse effects on export modules that could not export trackers containing no information. As a sidenote we
will write down in the doco that an export module should not expect empty trackers with no keyframes to be sent

### 2.2.2

* The last change to PFMatchit exporter had adverse effects on pftrack files, now fixed.
* Pipeline now has it's own exceptions, all inheriting from RuntimeError

### 2.2.1

* April fool!
* PFMAtchit requires LF in it's files instead of CRLF, but our FPTrack exporter used CRLF. Now fixed.
* Changed PFMatchit exporter to export .txt files instead of .2dt

### 2.2.0

* Improve documentation substantially
* Changed the Import::Base interface yo use enumeration instead of @receiver.
Upside: This allows us to convert importers to an array of trackers and other niceties.
Downside: stream_parse will be deprecated. It is however still available for backwards compatibility
  
### 2.1.1

* Fix handling of Shake scripts containing stabilizer nodes with no animation
* Remove underscores from tracker names exported to Syntheyes to prevent spaces from being generated

### 2.1.0
* Adds PFMatchit import support. Also all PFTrack imported cameras will have a camera name injected into the tracker
* Adds a PFMatchit exporter (PFMatchit only wants cameras with numbers in the name)

### 2.0.2
* Compatible with Ruby 1.9.2
* Scaler tool now supports negative scaling factors

### 2.0.0
* Bugfix for PFTrack exports to contain cross-platform linebreaks (rn instead of n)

### 1.9.9

* Buffer the parsed trackers on disk or in a stream (all backwards-compatible). Substantially reduces conversion times and memory
  usage on huge files.

### 1.9.8

* Very minor changes and improvements
* The app will now tell you when you try to feed it an empty file
* Change Synetheyes exports to start with a standard frame and not a keyframe to make 1-frame trackers work
* Adds a flip tool to mirror a tracked comp

### 1.9.6

* Support Tracker nodes in Shake scripts that come from an old (ages old!) Shake version
* Only parse channels that are actually relevant in the Flame importer

### 1.9.5

* More stringently check for trackers in the Shake script importer (helps from recognizing arbitrary variables as trackers)
* Increase the size of the in-mem string export buffer

### 1.9.4

* Fix the boujou exporter to not crash boujou 5

### 1.9.3

* Add direct export to boujou feature tracks
* Automatically check for new versions and alert the user that he needs an update
* Add tests for the commandline binary itself

### 1.9.2

* Fix a crasher when the progress bar was being set higher than 100 percent

### 1.9.1

* Fix a Pipeline bug introduced with the last version

### 1.9.0

* Use proper progress bars
* Allow proper chaining of tools in the commandline app - you can now apply many tools of the same nature in chain, and they will be ordered correctly
* Small rewrites to Pipeline::Base (changes API slightly - please consult the docs)

### 1.8.4

* Fix PFTrack imports neglecting the feature name if it only contained digits

### 1.8.3

* Fix faulty remaining trackers report being sent from the pipeline

### 1.8.2

* Fix the bug in the Flame exporter that was convincing Flame that there is only one tracker in the setup
* Buffer temporary outputs to String buffers until they reach a certain size. Helps with tempfile pollution and IO speed

### 1.8.1

* Add Flame stabilizer export support

### 1.7.5

* Use a special IO so that we can display progress when parsing/reading a file (based on the IO offset)

### 1.7.4

* Introduce an intentional gap in the reference exports to test trackers with gaps
* Export Syntheyes paths as normal frames, not as keyframes. This produces better solves by not overconstraining the solver
	(Without this TransitionFrms, a crucial parameter in SY, seizes to work)
* Add a LengthCutoff tool that allows you to remove trackers that have less than X keyframes in them from the export

### 1.7.3

* Fixed the --only option in the commandline binary

### 1.7.2

* Add a Lerp tool that linearly interpolates missing keyframes (USE CAREFULLY!)
* Prevent the Shake lexer from walking into the woods on files that are certainly wrong
* Export proper project length with Nuke scripts
* Ensure preamble for Nuke exports does not get overriden in width/height

### 1.7.1

* Fix Ruby 1.9 compatibility

### 1.7.0

* Fix edge cases of specific comp sizes outputting incorrect exports for Equalizer 3 and MatchMover

### 1.6.9

* Make the commandline progress reports shorter

### 1.6.8

* Fix frame gap handling for repeating gaps in the Nuke importer

### 1.6.7

* Fix frame gap sizes in the Nuke exporter (thanks Michael Lester)

### 1.6.6

* Handle Hermite cuves in Shake scripts

### 1.6.5

* Adds the --only option for the tracksperanto binary to only export a specific format
* Automatically unlink tempfiles in the Equalizer4 exporter

### 1.6.4

* Adds Boujou 2d feature import support (to export for Boujou use the Shake text format)

### 1.6.3

* Fixes the Shake importer so that it doesn't apply correlation curves if they are not present or constantized to 1

### 1.6.2

* Fixes the Reformat tool to not suppress the end_export call. Crucial for exporters that
  use end_export to finalize output
  
### 1.6.0

* MatchMover has top-left coordinates - fixed for both import and export
* Prevent Tracker from being Array#flatten'ed

### 1.5.7

* Add a Prefix tool that prefixes tracker names

### 1.5.6

* Rerelase of 1.5.5 without the huge binary blob in the middle
* Interpret Shake NSplines as Linear instead of discarding them

### 1.5.4

* Fix a bug in the Shake importer for tracks that have no animation

### 1.5.37

* Fix a bug in the Nuke importer for tracks that have no animation

### 1.5.2

* Fix Windows-specific issue (Tempfile-related) in the Equalizer4 exporter
* Add Export::Base#just_export and Tool::Base#just_export

### 1.5.0

* Implement support for older 3DE exports (in and out)

### 1.4.0

* Implement MayaLive import and export

### 1.3.1

* Implement 3DE import and export

### 1.2.7

* Improved progress reporting

### 1.2.6

* Add const_name to the classes being introspected most often

### 1.2.5

* Reset residual on Syntheyes imports to 0

### 1.2.4

* Write to files in binary mode

### 1.2.3

* Support both PFTrack 4 and 5 

### 1.2.1

* Fixed the binary that was not able to properly pass the importer class to the pipeline

### 1.2.0

* Add experimental MatchMoverPro import and export support
* Rewrite the Shake parser, support MatchMove and Stabilize nodes and many tracks per node
* Officially add and test the Reformat tool
* Remove the Close tool and close IOs automatically at pipeline end
* Much improved documentation
* Use IO as base for all the parsers (if a parser needs a string it will have to read by himself)
* Much improved test coverage
* Support Nuke import and export

### 1.0.0

* Welcome