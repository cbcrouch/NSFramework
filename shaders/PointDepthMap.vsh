//
//  PointDepthMap.vsh
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410

layout (location=0) in vec3 v_position;

uniform mat4 model;

void main() {
    gl_Position = model * vec4(v_position, 1.0);
}
