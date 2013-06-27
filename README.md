obuild
======

Build system built on [OMake](http://omake.metaprl.org).

In order to build a project, copy it into the obuild source path (`src` by
default) and run `omake`. The repository includes the subdirectories and git
submodules for all projects that use obuild, but you can delete those if you
just want to build some projects. It doesn't matter in which path the projects
reside, as long as they are under the source path and they are somehow
referenced from the OMakeroot. This happens automatically if you link or copy
`rules/subdirs.om` to the subdir's OMakefile.
