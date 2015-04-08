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

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 texCoords;

out vec3 f_normal;
out vec3 f_position;
out vec2 f_texcoord;

void main() {
    f_position = vec3(model * vec4(position, 1.0f));
    f_normal = mat3(transpose(inverse(model))) * normal;
    f_texcoord = texCoords;

    gl_Position = UBO.projection * UBO.view *  model * vec4(position, 1.0f);
}
