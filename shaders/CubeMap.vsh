//
//  CubeMap.vsh
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#version 410

layout(std140) uniform UBOData {
    mat4 view;
    mat4 projection;
} UBO;

layout (location = 0) in vec4 v_position;

out vec3 f_texcoord;

void main()
{
    f_texcoord = v_position.xyz;
    gl_Position = UBO.projection * UBO.view * vec4(v_position.xyz, 1.0f);
}
