//
//  PointDepthMap.gsh
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

// NOTE: GLSL version 410 corresponds to OpenGL 4.1
#version 410

layout (triangles) in;
layout (triangle_strip, max_vertices=18) out;

uniform mat4 shadowTransforms[6];

out vec4 fragPos;

void main() {
    for(int face=0; face<6; ++face) {
        gl_Layer = face; // built-in variable that specifies to which face we render
        for(int i=0; i<3; ++i) {
            fragPos = gl_in[i].gl_Position;
            gl_Position = shadowTransforms[face] * fragPos;
            EmitVertex();
        }
        EndPrimitive();
    }
}
