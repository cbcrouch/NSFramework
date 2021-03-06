//
//  CubeMap.fsh
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#version 410

uniform samplerCube cubeMap;

in vec3 f_texcoord;

out vec4 fragColor;

void main() {
    fragColor = texture(cubeMap, f_texcoord);
}
