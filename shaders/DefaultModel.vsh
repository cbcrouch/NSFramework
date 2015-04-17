//
//  DefaultModel.vsh
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#version 410

layout(std140) uniform UBOData {
    mat4 view;
    mat4 projection;
} UBO;

uniform mat4 model;


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

    gl_Position = UBO.projection * UBO.view *  model * v_position;
}
