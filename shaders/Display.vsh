//
//  Display.vsh
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//


// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410


layout (location = 0) in vec2 v_position;
layout (location = 1) in vec2 v_texcoord;

out vec2 f_texcoord;

void main() {
    f_texcoord = v_texcoord;
    gl_Position = vec4(v_position.x, v_position.y, 0.0f, 1.0f);
}
