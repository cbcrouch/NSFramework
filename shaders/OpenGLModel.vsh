//
//  OpenGLModel.vsh
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410


layout(std140) uniform UBOData {
    mat4 view;
    mat4 projection;
} UBO;

// uniforms
uniform mat4 model;

// attributes
in vec4 v_vertex;
in vec4 v_normal;
in vec3 v_texcoord;

// outputs to next stage
out vec4 f_vertex;
out vec4 f_normal;
out vec3 f_texcoord;

//
// TODO: use layout qualifier to allow for program separation linkage e.g.:
//

//layout (location = 0) out vec4 color;
//layout (location = 1) out vec2 texCoord;
//layout (location = 2) out vec3 normal;

void main (void) {
    // pass through texcoord fragment shader
    f_texcoord = v_texcoord;
    f_vertex = UBO.view * model * v_vertex;

    //
    // TODO: should only calculate the modelview matrix once then reuse
    //

    // calculate the eye space normal vector
    mat4 M = transpose(inverse(UBO.view * model)); // this is the noraml matrix
    vec3 N = normalize(mat3(M) * v_normal.xyz);
    f_normal = vec4(N, 1.0);

    // calculate the final vertex position (NOTE: correct order for right-handed coordinate system)
    vec4 vertPos = UBO.projection * UBO.view * model * v_vertex;

    // NOTE: for projective texturing: vec4 projPos = projBias * projection * view * model * position

    gl_Position = vertPos;
}
