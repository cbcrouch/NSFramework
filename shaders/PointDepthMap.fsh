//
//  PointDepthMap.fsh
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410

uniform vec3 lightPos;
uniform float farPlane;

in vec4 fragPos;

void main (void) {
    float lightDistance = length(fragPos.xyz - lightPos);

    // map to [0 1] range by dividing out far plane
    lightDistance = lightDistance / farPlane;

    gl_FragDepth = lightDistance;
}
