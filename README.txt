= TRCKSPERANTO

Tracksperanto is a universal 2D-track translator between many apps.

Import support:
* Shake script (one tracker node per tracker)
* Shake tracker node export (textfile with many tracks per file), also exported by Boujou and others
* PFTrack 2dt files
* Flame .stabilizer setups
* Syntheyes 2D tracking data exports (UV coordinates)

Export support:

* Shake text file (many trackers per file), also accepted by Boujou
* Flame .stabilizer setup
* PFTrack 2dt file (with residuals)
* Syntheyes 2D tracking data import (UV coordinates)

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
Exporters, Importers and Middlewares. Any processing chain usually works like this:

1) The tracker file is read and trackers and their keyframes are extracted, converting them to the internal representation.
   For some formats you need to supply the width and height of the source material
2) The trackers and their keyframes are dumped to all export formats Tracksperanto supports, optionally passing through middleware

== Internal coordinate system

Frame numbers start from zero (frame 0 is first frame of the track).

Tracksperanto uses the Shake coordinates as base. Image is Y-positive, X-positive, absolute pixel values up and right (zero is in the
lower left corner). Some apps use a different coordinate system so translation will take place on import or on export, respectively.

We also use residual and not correlation (residual is how far the tracker strolls away, correlation is how sure the tracker is
about what it's doing). Residual is the inverse of correlation (with total correlation of one the residual excursion becomes zero).

== Limitations

Information about the search area, reference area and offset is not passed along (outside of scope for the app and different trackers handle
these differently, if at all). For some modules no residual will be passed along (3D tracking apps generally do not export residual with
backprojected 3D features).
