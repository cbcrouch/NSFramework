//
//  NFAssetUtils.m
//  NSGLFramework
//
//  Created by cbcrouch on 2/26/15.
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetUtils.h"

@implementation NFAssetUtils

+ (NFFace_t) calculateFaceWithPoints:(NFVertex_t *)vertices withIndices:(GLushort [3])indices {
    NFFace_t face;
    NSInteger p1, p2, p3;

    p1 = indices[0];
    p2 = indices[1];
    p3 = indices[2];

    face.indices[0] = indices[0];
    face.indices[1] = indices[1];
    face.indices[2] = indices[2];

    // for a triangle with points p1, p2, p3

    // U = p2 - p1
    // V = p3 - p1
    // N = U X V

    // manually calculated cross product
    // Nx = UyVz - UzVy
    // Ny = UzVx - UxVz
    // Nz = UxVy - UyVx

    GLKVector4 v1 = GLKVector4Make(vertices[p1].pos[0], vertices[p1].pos[1], vertices[p1].pos[2], vertices[p1].pos[3]);
    GLKVector4 v2 = GLKVector4Make(vertices[p2].pos[0], vertices[p2].pos[1], vertices[p2].pos[2], vertices[p2].pos[3]);
    GLKVector4 v3 = GLKVector4Make(vertices[p3].pos[0], vertices[p3].pos[1], vertices[p3].pos[2], vertices[p3].pos[3]);

    GLKVector4 U = GLKVector4Subtract(v2, v1);
    GLKVector4 V = GLKVector4Subtract(v3, v1);
    GLKVector4 N = GLKVector4CrossProduct(U, V);

    N = GLKVector4Normalize(N);

    face.normal[0] = N.x;
    face.normal[1] = N.y;
    face.normal[2] = N.z;
    face.normal[3] = N.w;

    // length between two 3d points
    // xd = x2 - x1
    // yd = y2 - y1
    // zd = z2 - z1
    // d = sqrt(xd^2 + yd^2 + zd^2)

    GLKVector4 vd = GLKVector4Subtract(v2, v1);
    float a = sqrtf(powf(vd.x, 2) + powf(vd.y, 2) + powf(vd.z, 2));

    vd = GLKVector4Subtract(v3, v1);
    float b = sqrtf(powf(vd.x, 2) + powf(vd.y, 2) + powf(vd.z, 2));

    vd = GLKVector4Subtract(v3, v2);
    float c = sqrtf(powf(vd.x, 2) + powf(vd.y, 2) + powf(vd.z, 2));

    // Heron's Formula (triangle surface area):
    // a, b, and c are the lengths of the triangle sides
    // s = (a + b + c)/2.0
    // A = sqrt(s(s-a)(s-b)(s-c))

    float s = (a + b + c) / 2.0f;
    face.area = sqrtf(s*(s-a)*(s-b)*(s-c));

    return face;
}

+ (GLKVector4) calculateAreaWeightedNormalOfIndex:(GLushort)index withFaces:(NSArray *)faceArray {
    GLKVector4 vector;
    memset(&vector, 0x00, sizeof(GLKVector4));

    NFFace_t encodedFace;
    GLKVector4 normal;
    for (id obj in faceArray) {
        NSValue *value = obj;
        [value getValue:&encodedFace];

        if (encodedFace.indices[0] == index || encodedFace.indices[1] == index || encodedFace.indices[2] == index) {
            for (int i=0; i<4; ++i) {
                normal.v[i] = encodedFace.normal[i];
            }
            normal = GLKVector4MultiplyScalar(normal, encodedFace.area);
            vector = GLKVector4Add(vector, normal);
        }
    }

    vector = GLKVector4Normalize(vector);
    return vector;
}

+ (GLKVector4) calculateAngleWeightedNormalOfVertex:(GLfloat[4])vertex withFaces:(NSArray *)faceArray {

    NSAssert(NO, @"ERROR: this function is NOT implemented, yet...");

    GLKVector4 vector;
    memset(&vector, 0x00, sizeof(GLKVector4));

    //
    // TODO: should only use this method when vertex and faces are contained within a smoothing group
    //

    // cos(theta) = A dot B if A and B have been normalized

    // A dot B is then bound between [-1 1] at which point would then have to get the angle based on that or
    // could the weighting scaling be performed with just that bound ??

    // 1 means that vectors lie in the same direction
    // -1 means that vectors lie in opposite direction
    // 0 means they are 90 degress apart


    NFFace_t encodedFace;
    //GLKVector4 normal;
    for (id obj in faceArray) {
        NSValue *value = obj;
        [value getValue:&encodedFace];

        //
        // TODO: check if vertex provided is contained within the face
        //
    }
    
    vector = GLKVector4Normalize(vector);
    return vector;
}

@end
