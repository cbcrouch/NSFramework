//
//  DefaultModel.vsh
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#version 410


//
// TODO: add support for shadow maps
//


layout(std140) uniform UBOData {
    mat4 view;
    mat4 projection;
} UBO;

uniform mat4 model;


//
// TODO: add support for passing in a light space matrix for each active light
//
uniform mat4 lightSpace;
uniform mat4 spotLightSpace;

out vec4 f_posLightSpace;
out vec4 f_posSpotLightSpace;


//
// TODO: make position and normal vec3
//
layout (location = 0) in vec4 v_position;
layout (location = 1) in vec4 v_normal;
layout (location = 2) in vec3 v_texcoord;

out vec3 f_normal;
out vec3 f_position;
out vec2 f_texcoord;


void main() {
    f_position = vec3(model * v_position);
    f_normal = mat3(transpose(inverse(model))) * v_normal.xyz;
    f_texcoord = v_texcoord.xy;

    f_posLightSpace = lightSpace * vec4(f_position, 1.0);
    f_posSpotLightSpace = spotLightSpace * vec4(f_position, 1.0);

    gl_Position = UBO.projection * UBO.view *  model * v_position;
}
