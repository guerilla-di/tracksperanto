Tracksperanto is a universal 2D-track translator between many apps.

## Is it any good?

Yes.

## Why Tracksperanto?

Historically, every matchmoving app uses it's own UI for tracking 2D features.
Unfortunately, the UIs of these are all different and not very user-friendly. It happens
that an app cannot solve a shot that another one will, but you usually have to redo your 2D
tracks in each one of them.

### Efficiency when doing tracks

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
applications at once.

### Evaluating different camera solvers

Since your 2D tracking data is now freely interchangeable you can load the same tracks
into multiple 3D tracking applications and see which one gives you a better solve.
Should all the 3D camera trackers fail, you can still take your tracks into the 2D
compositing world to do the job. 

### Processing 2D tracking data

Sometimes you need to offset your tracks in time, or resize them to a different pixel format.
Very few apps allow you to convert your tracks in one step from format to format - like doing
an unproportional scale on the tracks, or moving them a few pixels left and right. This comes 
at a high cost if the footage you are tracking came cropped or in a wrong aspect - the only 
way to solve the shot will be to retrack it from scratch.

To circumvent this, Tracksperanto allows you to apply transformations to the tracking data
that you export - and you can apply multiple transformations if desired.

## Using Tracksperanto from the command line

To run on your own computer, make sure you have Ruby installed. Versions from 1.8.7
and up are supported.
    
    $ ruby -v
    ruby 2.0.0p247 (2013-06-27 revision 41674) [x86_64-darwin13.0.0]

Then install tracksperanto. It will be downloaded and unpacked automatically for you by the
RubyGems system:

    $ sudo gem install tracksperanto

Then you will have a "tracksperanto" binary in your $PATH, which you can use like this:

    $ tracksperanto -w 1920 -h 1080 /Films/Blockbuster/Shots/001/script.shk

To see the supported options, run

    $ tracksperanto --help | more

The converted files will be saved in the same directory as the source, if resulting
converted files already exist <b>they will be overwritten without warning</b>.

## Using Tracksperanto through the web

For situations where you cannot install anything on your machine, or you run a shitty OS that cannot
run Ruby decently, or you are in a locked-down environment, we offer a web-enabled version of
Tracksperanto at the following URL:

    http://tracksperanto.guerilla-di.org/

This is a web-app which is always in lock-step with the main Tracksperanto in terms of versions,
features and bug fixes. As a matter of principle, we reserve the right to use anything you upload
to the web version for fixing bugs in Tracksperanto. Note that we usually scrub all the studio-specific
data (like script and footage paths) from the files before adding them to the repo.

If you want your own copy of the web application at your facility we can discuss that, but it's not free.

## Format support

--- 
 
### Formats Tracksperanto can read
 
* 3DE v3 point export file
* 3DE v4 point export file
* Boujou feature tracks export
* Flame .stabilizer file
* MatchMover REALVIZ Ascii Point Tracks .rz2 file
* MatchMover RZML .rzml file
* Maya Live track export file
* Nuke .nk script file with Tracker, Reconcile3D, Transform2D, PlanarTracker and CornerPin nodes
* PFTrack/PFMatchit .2dt file
* Shake .shk script file
* Shake .txt tracker file and Nuke CameraTracker auto tracks export
* Syntheyes "All Tracker Paths" export .txt file
* Syntheyes "Tracker 2-D paths" file
 
### Formats Tracksperanto can export to
 
* 3DE v3 point export .txt file
* 3DE v4 point export .txt file
* AfterEffects .jsx script generating null layers
* Autodesk 3dsmax script for nulls on an image plane
* Autodesk Softimage nulls Python script
* Bare Ruby code
* Flame/Smoke 2D Stabilizer setup
* Flame/Smoke 2D Stabilizer setup (v. 2014 and above)
* Flame/Smoke 2D Stabilizer setup (v. 2014 and above) for corner pins
* Flame/Smoke 2D Stabilizer setup for bilinear corner pins
* MatchMover REALVIZ Ascii Point Tracks .rz2 file
* Maya ASCII scene with locators on an image plane
* MayaLive track export
* Nuke .nk script
* Nuke CameraTracker node autotracks (enable import/export in the Tracking tab)
* PFTrack v4 .2dt file
* PFTrack v5 .2dt file (single camera)
* PFTrack2011/PFMatchit .txt file (single camera)
* Shake trackers in a .txt file
* Syntheyes 2D tracker paths file
* boujou feature tracks
 
---


## Editing your tracks while converting

Tracksperanto has a number of features to scale, move, slip, distort and rename trackers.
Consult the --help option to see what is available.

## Development

[![Gem Version](https://badge.fury.io/rb/tracksperanto.svg)](http://badge.fury.io/rb/tracksperanto)
[![Travis](https://secure.travis-ci.org/guerilla-di/tracksperanto.png)](https://travis-ci.org/guerilla-di/tracksperanto)

If you are interested in reusing Tracksperanto's code or adding modules to the software consult
the [short developer introduction](https://github.com/guerilla-di/tracksperanto/blob/master/CONTRIBUTING.md)

## Limitations

Information about the search area, reference area and offset is not passed along (outside
of scope for the app and different trackers handle these differently, if at all). For some
modules no residual will be passed along (3D tracking apps generally do not export residual
with backprojected 3D features).

## Licensing

Tracksperanto is made avalable under the MIT license that is included in the package.
