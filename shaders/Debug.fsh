//
//  OpenGLModel.fsh
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410


//
// TODO: try putting all shader code in one file and use preprocessor to mark off sections
//       (when the renderer loads the shader it will need to setup the correct preprocessor defines
//       but specify the version number first, version number will need to be removed from source)
//

// to set defines:
//char* shader_source[2] = { "#version 410\n#define VERTEX_SHADER\n", file_source };
//glShaderSource(shader_handle, 2, shader_source, NULL);

#ifdef VERTEX_SHADER

// vertex shader code

#endif

#ifdef FRAGMENT_SHADER

// fragment shader code

#endif


uniform sampler2D texSampler;

//
// TODO: add layout qualifers e.g.:
//
// #define IN_POSITION 0
// layout(location = IN_POSITION) in vec4 f_vertex;
//
in vec3 f_position;
in vec3 f_normal;

in vec4 f_color;

out vec4 fragColor;

/*
subroutine vec4 texFunc_t(sampler2D sampler, vec3 coords);
subroutine uniform texFunc_t TexFunction;

subroutine(texFunc_t)
vec4 NormalizedTexexlFetch(sampler2D sampler, vec3 coords) {
    return texture(texSampler, coords.xy);
}

subroutine(texFunc_t)
vec4 ExplicitTexelFetch(sampler2D sampler, vec3 coords) {
    ivec2 itexcoord;

    // NOTE: currently only looking at the mantissa bits in order to avoid a denormal float
    //       (need to confirm this is true)
    itexcoord.x = 0x007fffff & floatBitsToInt(coords.x);
    itexcoord.y = 0x007fffff & floatBitsToInt(coords.y);
    return texelFetch(texSampler, itexcoord, 0);
}
*/

void main (void) {
    fragColor = f_color;
}
