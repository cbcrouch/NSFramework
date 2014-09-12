//
//  OpenGLModel.fsh
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//


// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410


uniform sampler2D texSampler;

//uniform vec4 Ia; // ambient light
//uniform float I; // light intensity

//
// TODO: add layout qualifers e.g.:
//
// #define IN_POSITION 0
// layout(location = IN_POSITION) in vec4 f_vertex;
//
in vec4 f_vertex;
in vec4 f_normal;
in vec3 f_texcoord;

//
// TODO: use layout qualifier to allow for program separation linkage e.g.:
//       (note different names)
//

//layout (location = 0) in vec4 diffuseAlbedo;
//layout (location = 1) in vec2 texCoord;
//layout (location = 2) in vec3 cameraSpaceNormal; // viewVectorNormal


out vec4 fragColor;

const vec3 lightPos = vec3(2.0, 2.25, -2.5);

const vec4 sceneColor= vec4(0.5, 0.25, 0.25, 1.0);

const vec4 matAmbient = vec4(0.2, 0.2, 0.2, 1.0);
const vec4 matDiffuse = vec4(0.8, 0.8, 0.8, 1.0);
const vec4 matSpecular = vec4(0.1, 0.1, 0.1, 1.0);

const vec4 lightAmbient = vec4(0.25, 0.25, 0.25, 1.0);
const vec4 lightDiffuse = vec4(0.25, 0.25, 0.25, 1.0);
const vec4 lightSpecular = vec4(0.25, 0.25, 0.25, 1.0);

const float shininess = 0.1;



subroutine vec4 texFunc_t(sampler2D sampler, vec3 coords);
subroutine uniform texFunc_t TexFunction;

subroutine(texFunc_t)
vec4 NormalizedTexexlFetch(sampler2D sampler, vec3 coords) {
    return texture(texSampler, coords.xy);
}

subroutine(texFunc_t)
vec4 ExplicitTexelFetch(sampler2D sampler, vec3 coords) {
    ivec2 itexcoord;

    //
    // TODO: currently only looking at the mantissa bits in order to avoid a denormal float
    //       (need to confirm this is true)
    //
    itexcoord.x = 0x007fffff & floatBitsToInt(coords.x);
    itexcoord.y = 0x007fffff & floatBitsToInt(coords.y);

    return texelFetch(texSampler, itexcoord, 0);
}



void main (void) {
    vec3 L = normalize(lightPos - f_vertex.xyz);
    vec3 E = normalize(-f_vertex.xyz);
    vec3 R = normalize(-reflect(L, f_normal.xyz));

    // calculate the ambient term
    vec4 Iamb = matAmbient * lightAmbient;

    // calculate the diffuse term
    vec4 Idiff = (matDiffuse * lightDiffuse) * max(dot(f_normal.xyz, L), 0.0);

    // calculate the specular term
    vec4 Ispec = (matSpecular * lightSpecular) * pow(max(dot(R, E), 0.0), 0.3 * shininess);

    // write total color
    fragColor = TexFunction(texSampler, f_texcoord) + Iamb + Idiff + Ispec;
}
