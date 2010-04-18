= Tracksperanto

* http://guerilla-di.org/tracksperanto

== Description

Tracksperanto is a universal 2D-track translator between many apps.

== Why Tracksperanto?

Historically, every matchmoving app uses it's own UI for tracking 2D features.
Unfortunately, the UIs of these are all different and not very user-friendly. It happens
that an app cannot solve a shot that another one will, but you usually have to redo your 2D
tracks in each one of them.

Another problem with today's matchmoving apps is that they are vastly inefficient when
doing 2D tracks. Almost all of them use OpenGL and want to load the whole frame into memory
at once. When doing tracks of long shots at high resolutions (like 2K and HD), especially
on 32bit platforms, the app usually cannot even cache the whole shot and tracking is very
very slow.

Compositing apps, in contrast, are very efficient. Both Shake and Nuke offer very
fast trackers because they have tiling image engines and can load only the search area
for the tracker into memory and not a pixel more. When you use manual feature selection 
you can create many tracks quickly even without having fast IO. Flame is also very fast
since it has virtually zero IO overhead thanks to it's fast storage. Compositing apps
also allow for precise, local preprocessing of tracking features like boosting contrast,
doing expensive (especially temporal) denoise, blurs and so on, while matchmoving apps
offer only a single, global preprocessing step (like a LUT or a gamma curve adjustment)
which is not adequate for all of the features being tracked.

So it's very natural to track in a modern compositing app that has selective image
loading, and then export one single group of tracks into all of the matchmoving
applications at once. Also, you can always escape into the 2D world if no 3D app proves
to be adequate. If you need to move from one app to another, you won't have to retrack.

Another issue with tracks is adjusting to formats. Very few apps allow you to convert your
tracks in one stop from format to format - like doing an unproportional scale on the
tracks, or moving them a few pixels left and right. This comes at a high cost if the
footage you are tracking came cropped or in a wrong aspect - the only way to solve the shot
will be to retrack it from scratch. Tracksperanto allows you to work around this
by applying simple transformations to the tracks.

== Licensing

Tracksperanto is made avalable under the MIT license that is included in the package.

== Usage

The main way to use Tracksperanto is with the the supplied "tracksperanto" binary, like so:

 tracksperanto -w 1920 -h 1080 /Films/Blockbuster/Shots/001/script.shk

-w and -h stand for Width and Height and define the size of your comp (different tracking
apps use different coordinate systems and we need to know the size of the comp to properly
convert these). Some formats contain clear hints on the size of the comp, but most don't -
for formats that do contain them you don't need to supply anything.
You also have additional options like -xs, -ys and --slip - consult the usage info for the tracksperanto binary.

The converted files will be saved in the same directory as the source, if resulting
converted files already exist <b>they will be overwritten without warning</b>.

== Format support

Import and export support:
* Nuke v5 script (Tracker3 nodes, also known as Tracker in the UI - this is the node that you track with)
* Shake tracker node export (textfile with many tracks per file)
* PFTrack 2dt files (version 4 and 5)
* Syntheyes 2D tracking data exports
* 3DE point exports (as output by the default script) - versions 3 and 4
* MatchMover Pro .rz2
* MayaLive track export (square pixel aspect only, you will need to write some extra code to convert that)
* Flame .stabilizer file
* Boujou feature track export

Import only:
* Shake script (Tracker, Matchmove and Stabilize nodes embedded in ANY shake script)

== Modularity

Tracksperanto is very modular and can process data passing through it (like
scaling a proxy track up). Internally, Tracksperanto talks Exporters, Importers and
Middlewares. Any processing chain (called a Pipeline) usually works like this:

* Tracker file is read and trackers and their
  keyframes are extracted, converting them to
  the internal representation.
* Trackers and their keyframes are dumped to all export
  formats Tracksperanto supports, optionally passing through Middleware


== Limitations

Information about the search area, reference area and offset is not passed along (outside
of scope for the app and different trackers handle these differently, if at all). For some
modules no residual will be passed along (3D tracking apps generally do not export residual
with backprojected 3D features).

== Extending Tracksperanto

=== Importing your own formats

You can easily write a Tracksperanto import module - refer to Tracksperanto::Import::Base
docs. Your importer will be configured with width and height of the comp that it is importing, and will get an IO 
object with the file that you are processing. The parse method should then return an array of Tracksperanto::Tracker objects which
are themselves arrays of Tracksperanto::Keyframe objects.

=== Exporting your own formats

You can easily write an exporter. Refer to the Tracksperanto::Export::Base docs. Note that your exporter should be able to chew alot of data
(hundreds of trackers with thousands of keyframes with exported files growing up to 5-10 megs in size are not uncommon!). This means that
the exporter should work with streams (smaller parts of the file being exported will be held in memory at a time).

=== Ading your own processing steps

You probably want to write a Middleware (consult the Tracksperanto::Middleware::Base docs) if you need some processing applied to the tracks
or their data. A Middleware is just like an export module, except that instead it sits between the exporter and the exporting routine. Middlewares wrap export
modules or each other, so you can stack different middleware modules together (like "scale first, then move").

=== Writing your own processing routines

You probably want to write a descendant of Tracksperanto::Pipeline::Base. This is a class that manages a conversion from start to finish, including detecting the
input format, allocating output files and building a chain of Middlewares to process the export. If you want to make a GUI for Tracksperanto you will likely need
to write your own Pipeline class or reimplement parts of it.

=== Reporting status from long-running operations

Almost every module in Tracksperanto has a method called report_progress. This method is used to notify an external callback of what you are doing, and helps keep
the software user-friendly. A well-behaved Tracksperanto module should manage it's progress reports properly.
