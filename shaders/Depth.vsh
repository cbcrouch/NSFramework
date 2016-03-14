//
//  Depth.vsh
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410


//
// TODO: may want to rename the projection matrix to lightSpaceMatrix
//       or something similiar
//
uniform mat4 projectionView;
uniform mat4 model;

//
// TODO: will need to change this to a vec3 once default vertex format
//       has been updated to use float[3] or GLKVector3f
//
layout (location = 0) in vec4 v_position;

void main() {
    //gl_Position = projectionView * model * vec4(v_position.xyz, 1.0f);
    gl_Position = projectionView * model * v_position;
}
