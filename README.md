NSFramework
=============

What is it?
-----------

A simple Cocoa application for reading Wavefront obj files and rendering them in OpenGL. This project is
a hobby project that will be a perpetual WIP as its primary purpose is to expand my knowledge of
Objective-C and Cocoa more than anything else. Work will be slow going given that I am a family man and
have other hobby projects as well.

Beware of hardcoded paths!

The project is configured to use C11 (with __STRICT_ANSI__ manually undefined), and ARC has been disabled.
These decisions were made to avoid being dependent on non-standard language/compiler features and because
memory allocations will be managed manually.

Dependencies
------------

OS X 10.10
OpenGL 4.1 compatible GPU

Building
--------

### Prerequisites

XCode 6.3
(XCode Command Line Tools optional but recommended)

### Getting source

	git clone git://github.com/cbcrouch/NSFramework.git

### Building

Launch XCode and build

Internals
---------

Currently using C11 without GNU extensions, though __STRICT_ANSI__ has been undefined, and NOT using ARC.

Assets
------

If you are in need of Wavefront obj files to parse:
- http://graphics.cs.williams.edu/data/meshes.xml
- http://graphics.stanford.edu/~mdfisher/Data/Meshes/bunny.obj

License
-------

Copyright 2015 Casey Crouch. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
