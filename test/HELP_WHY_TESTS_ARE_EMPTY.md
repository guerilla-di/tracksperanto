Tracksperanto has a huge test corpus of source and destination files, which is stored in the project's Github repo.
This is why the repo is so big. Bundling tests with the tracksperanto gem increases the size from 100+ KB to
over 4 MB, and most people installing Tracksperanto do not need this test data.

If you intend to actually write code that uses Tracksperanto or to fix
a bug, you will most definitely need all the test data. In that case, just do a git checkout. Check
the Tracksperanto::VERSION and check out the corresponding Git tag from our
Github repository at https://github.com/guerilla-di/tracksperanto
