//
//  DirectionalDepthMap.fsh
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410

//
// NOTE: no processing needs to be done on the fragments and the
//       depth buffer will still be built correctly
//

void main (void) {
    // can explicity set the depth by using the following:
    //gl_FragDepth = gl_FragCoord.z;
}
