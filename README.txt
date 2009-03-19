= TRCKSPERANTO

Tracksperanto is a universal 2D-track translator between many apps.

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