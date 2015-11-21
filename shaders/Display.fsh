//
//  Display.fsh
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//


// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410


uniform sampler2D screenTexture;

in vec2 f_texcoord;

out vec4 color;

void main (void) {
    color = texture(screenTexture, f_texcoord);
}
