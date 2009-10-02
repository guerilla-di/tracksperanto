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

Compositing apps, in contrast, are very efficient in this. Both Shake and Nuke offer very
fast trackers because they can load only the search area for the tracker into memory and
not a pixel more. When you use manual feature selection you can create many tracks very
quickyl even without having fast IO. Flame is also very fast since it has virtually zero IO
overhead thanks to it's fast storage. Compositing apps also allow for precise, local
preprocessing of tracking features like boosting contrast, doing expensive (especially
temporal) denoise, blurs and so on, while matchmoving apps offer only a single, global
preprocessing step (like a LUT or a gamma curve adjustment) which is not adequate for all
of the features being tracked.

It's thusly very natural to track in a modern compositing app that has selective image
loading, and then export one single group of tracks into all of the matchmoving
applications and figuring out which one gives a better camera solve. Also, you can always
escape into the 2D world if no 3D app proves to be adequate. If you need to move from one
app to another, you won't have to retrack.

Another issue with tracks is adjusting to formats. Very few apps allow you to convert your
tracks in one stop from format to format - like doing an unproportional scale on the
tracks, or moving them a few pixels left and right. This comes at a high cost of the
footage you are tracking came cropped or in a wrong aspect - the only way to solve the shot
will be to retrack it from scratch. Tracksperanto allows you to work around this
by applying simple transformations to the tracks.

== Usage

The main way to use Tracksperanto is to use the supplied "tracksperanto" binary, like so:

 tracksperanto -w 1920 -h 1080 /Films/Blockbuster/Shots/001/script.shk

-w and -h stand for Width and Height and define the size of your comp (different tracking
apps use different coordinate systems and we need to know the size of the comp to properly
convert these). You also have additional options like -xs, -ys and --slip - consult the
usage info for the tracksperanto binary.

The converted files will be saved in the same directory as the source, if resulting
converted files already exist <b>they will be overwritten without warning</b>.

== Format support

Import support:

* Flame .stabilizer file (not the .stabilizer.p blob format)
* Nuke script (Tracker3 nodes, also known as Tracker)
* Shake script (Tracker, Matchmove and Stabilize nodes)
* Shake tracker node export (textfile with many tracks per file)
* PFTrack 2dt files
* Syntheyes 2D tracking data exports
* 3DE point exports (as output by the default script)
* MatchMover Pro .rz2
* MayaLive track export (square pixel aspect only)

Export support:

* Shake text file (many trackers per file), also accepted by Boujou.
  May crash Shake with more than 4-5 tracks.
* PFTrack 2dt file (with residuals)
* Syntheyes 2D tracking data import (UV coordinates)
* Nuke script
* 3DE point exports (as accepted by the default import)
* MatchMover Pro .rz2
* MayaLive track export (square pixel aspect only)

== Modularity

Tracksperanto supports many export and import formats. It also can help when you need to
import and export the same format, but you need some operation applied to the result (like
scaling a proxy track up). Internally, Tracksperanto talks Exporters, Importers and
Middlewares. Any processing chain (called a Pipeline) usually works like this:

* Tracker file is read and trackers and their
  keyframes are extracted, converting them to
  the internal representation.
* Trackers and their keyframes are dumped to all export
  formats Tracksperanto supports, optionally passing through middleware

== Importing your own formats

You can easily write a Tracksperanto import module - refer to Tracksperanto::Import::Base
docs. Your importer should return an array of Tracksperanto::Tracker objects which
are themselves arrays of Tracksperanto::Keyframe objects.

== Exporting your own formats

You can easily write an exporter. Refer to the Tracksperanto::Export::Base docs.

== Limitations

Information about the search area, reference area and offset is not passed along (outside
of scope for the app and different trackers handle these differently, if at all). For some
modules no residual will be passed along (3D tracking apps generally do not export residual
with backprojected 3D features).
