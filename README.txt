= Tracksperanto

* http://guerilla-di.org/tracksperanto

== Description

Tracksperanto is a universal 2D-track translator between many apps.

== Usage

Import support:
* Flame .stabilizer file (not the .stabilizer.p blob format)
* Nuke script (Tracker3 nodes, also known as Tracker)
* Shake script (Tracker, Matchmove and Stabilize nodes)
* Shake tracker node export (textfile with many tracks per file), also exported by Boujou and others.
* PFTrack 2dt files
* Syntheyes 2D tracking data exports (UV coordinates)

Export support:

* Shake text file (many trackers per file), also accepted by Boujou. May crash Shake with more than 4-5 tracks.
* PFTrack 2dt file (with residuals)
* Syntheyes 2D tracking data import (UV coordinates)
* Nuke script

The main way to use Tracksperanto is to use the supplied "tracksperanto" binary, like so:
  
  tracksperanto -f ShakeScript -w 1920 -h 1080 /Films/Blockbuster/Shots/001/script.shk

ShakeScript is the name of the translator that will be used to read the file (many apps export tracks as .txt files so
there is no way for us to autodetect them all). -w and -h stand for Width and Height and define the size of your comp (different
tracking apps use different coordinate systems and we need to know the size of the comp to properly convert these). You also have
additional options like -xs, -ys and --slip - consult the usage info for the tracksperanto binary.

The converted files will be saved in the same directory as the source, if resulting converted files already exist ++they will be overwritten without warning++.

== Modularity

Tracksperanto supports many export and import formats. It also can help when you need to import and export the same format,
but you need some operation applied to the result (like scaling a proxy track up). Internally, Tracksperanto talks
Exporters, Importers and Middlewares. Any processing chain (called a Pipeline) usually works like this:

1) The tracker file is read and trackers and their keyframes are extracted, converting them to the internal representation.
2) The trackers and their keyframes are dumped to all export formats Tracksperanto supports, optionally passing through middleware

== Internal coordinate system

Frame numbers start from zero (frame 0 is first frame of the clip).

Tracksperanto uses Shake coordinates as base. Image is Y-positive, X-positive, absolute pixel values up and right (zero is in the
lower left corner). Some apps use a different coordinate system so translation will take place on import or on export, respectively.

We also use residual and not correlation (residual is how far the tracker strolls away, correlation is how sure the tracker is
about what it's doing). Residual is the inverse of correlation (with total correlation of one the residual excursion becomes zero).

== Importing your own formats

You can easily write a Tracksperanto import module - refer to Tracksperanto::Import::Base docs

== Exporting your own formats

You can easily write an exporter. Refer to the Tracksperanto::Export::Base docs.

== Limitations

Information about the search area, reference area and offset is not passed along (outside of scope for the app and different trackers handle
these differently, if at all). For some modules no residual will be passed along (3D tracking apps generally do not export residual with
backprojected 3D features).
