//
//  Debug.vsh
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410

layout(std140) uniform UBOData {
    mat4 view;
    mat4 projection;
} UBO;

uniform mat4 model;

layout (location = 0) in vec3 v_position;
layout (location = 1) in vec3 v_normal;
layout (location = 2) in vec4 v_color;

out vec3 f_position;
out vec3 f_normal;
out vec4 f_color;

void main() {
    f_position = vec3(model * vec4(v_position, 1.0f));
    f_normal = mat3(transpose(inverse(model))) * v_normal;
    f_color = v_color;

    gl_Position = UBO.projection * UBO.view * model * vec4(v_position, 1.0f);
}
