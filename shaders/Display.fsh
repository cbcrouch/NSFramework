//
//  Display.fsh
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//


// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410


uniform sampler2D screenTexture;

in vec2 f_texcoord;

out vec4 color;



//
// TODO: add subroutines for color effects, kernels, and depth buffer display
//



//
// TODO: set a uniform or subroutine for displaying depth buffer ?? or just #if it for now ??
//       (will need to update the display target processTransfer method with the
//       ability to specify which render target attachment to use)
//

/*
//out vec4 color;
//in vec2 TexCoords;
//uniform sampler2D depthMap;

uniform float near_plane;
uniform float far_plane;

//
// TODO: only linearize depth values if a perspective projection matrix was used (point and spot lights)
//

float linearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0; // Back to NDC
    return (2.0 * near_plane * far_plane) / (far_plane + near_plane - z * (far_plane - near_plane));
}

void grayScaleDepth() {
    float depthValue = texture(depthMap, TexCoords).r;
    //color = vec4(vec3(LinearizeDepth(depthValue) / far_plane), 1.0); // perspective
    color = vec4(vec3(depthValue), 1.0); // orthographic
}
*/



//
// TODO: clean this up and organize into a post-processing effects mechanism
//

const float offset = 1.0f / 300.0f; // 3x3 kernel
//const float offset = 1.0f / 500.0f; // 5x5 kernel ??


const float sharpenKernel[9] = float[](-1, -1, -1,
                                -1,  9, -1,
                                -1, -1, -1);

const float blurKernel[9] = float[](1.0 / 16, 2.0 / 16, 1.0 / 16,
                                    2.0 / 16, 4.0 / 16, 2.0 / 16,
                                    1.0 / 16, 2.0 / 16, 1.0 / 16);

const float edgeDetectKernel[9] = float[](1, 1, 1,
                                          1, -8, 1,
                                          1, 1, 1);


void main (void) {
    // inverted
    //    color = vec4(vec3(1.0 - texture(screenTexture, f_texcoord)), 1.0);

    // gray scale
    //    color = texture(screenTexture, f_texcoord);
    //    float average = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
    //    color = vec4(average, average, average, 1.0);



    // default
#if 1
    color = texture(screenTexture, f_texcoord);
#else
    // grayscale depth values
    float depthValue = texture(screenTexture, f_texcoord).r;
    color = vec4(vec3(depthValue), 1.0);
#endif



#if 0
    vec2 offsets[9] = vec2[](vec2(-offset, offset),   // top-left
                             vec2(0.0f,    offset),   // top-center
                             vec2(offset,  offset),   // top-right
                             vec2(-offset, 0.0f),     // center-left
                             vec2(0.0f,    0.0f),     // center-center
                             vec2(offset,  0.0f),     // center-right
                             vec2(-offset, -offset),  // bottom-left
                             vec2(0.0f,    -offset),  // bottom-center
                             vec2(offset,  -offset)); // bottom-right


    //float kernel[9] = sharpenKernel;
    //float kernel[9] = blurKernel;
    float kernel[9] = edgeDetectKernel;


    vec3 sampleTex[9];
    for(int i = 0; i < 9; i++) {
        sampleTex[i] = vec3(texture(screenTexture, f_texcoord.st + offsets[i]));
    }

    vec3 col = vec3(0.0);
    for(int i = 0; i < 9; i++) {
        col += sampleTex[i] * kernel[i];
    }
    
    color = vec4(col, 1.0);
#endif
}
