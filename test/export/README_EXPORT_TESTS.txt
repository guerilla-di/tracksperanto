Export tests are conformance tests. That means that:

1) An export is made using Tracksperanto 
2) This export gets checked by importing it into the main app 
that accepts such files
3) The export is compared with Tracksperanto output in the test

This means that unless you own an app that accepts this particular format
you cannot overwrite the export with your own since you got no way to verify
that the export works

The current test set consists of three trackers. First - two two parabolic curves that cross.
The first tracker goes left to right, the second right to left and they start at opposite
corners of the reference 1920x1080 export.

At the first point the track has the residual of 0, at the end of the curve - the biggest 
residual (PFTrack marks it red exactly at the last keyframe).

The third tracker has one keyframe and is positioned exactly in the middle.

In the middle of the curves a couple of keyframes is skipped to verify that proper gaps are written into the export.

When changing the export parameters you will need to overwrite all test exports, to do so set the environment variable
called TRACKSPERANTO_OVERWRITE_ALL_TEST_DATA