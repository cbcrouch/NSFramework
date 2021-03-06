//
//  NFAssetData+Procedural.m
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#import "NFAssetData+Procedural.h"
#import "NFAssetUtils.h"

static const char *g_faceType = @encode(NFFace_t);


@implementation NFAssetData (Procedural)

-(void) createGridOfSize:(NSInteger)size {
    // (size * 2) + 1 == number of lines
    // numLines * 2 == number of vertices per grid direction
    // gridDirVertices * 2 == total number of vertices (2 grid directions)
    const NSInteger numVertices = ((size * 8) + 4);

    NFDebugVertex_t vertices[numVertices];
    memset(vertices, 0x00, numVertices * sizeof(NFDebugVertex_t));

    int vertexIndex = 0;
    for (NSInteger i=-size; i<=size; ++i) {
        vertices[vertexIndex].pos[0] = (float)size;
        vertices[vertexIndex].pos[1] = 0.0f;
        vertices[vertexIndex].pos[2] = (float)i;

        vertices[vertexIndex].color[0] = 1.0f;
        vertices[vertexIndex].color[1] = 1.0f;
        vertices[vertexIndex].color[2] = 1.0f;
        vertices[vertexIndex].color[3] = 1.0f;

        vertices[vertexIndex+1].pos[0] = (float)-size;
        vertices[vertexIndex+1].pos[1] = 0.0f;
        vertices[vertexIndex+1].pos[2] = (float)i;

        vertices[vertexIndex+1].color[0] = 1.0f;
        vertices[vertexIndex+1].color[1] = 1.0f;
        vertices[vertexIndex+1].color[2] = 1.0f;
        vertices[vertexIndex+1].color[3] = 1.0f;

        vertexIndex += 2;
    }

    for (NSInteger i=-size; i<=size; ++i) {
        vertices[vertexIndex].pos[0] = (float)i;
        vertices[vertexIndex].pos[1] = 0.0f;
        vertices[vertexIndex].pos[2] = (float)size;

        vertices[vertexIndex].color[0] = 1.0f;
        vertices[vertexIndex].color[1] = 1.0f;
        vertices[vertexIndex].color[2] = 1.0f;
        vertices[vertexIndex].color[3] = 1.0f;

        vertices[vertexIndex+1].pos[0] = (float)i;
        vertices[vertexIndex+1].pos[1] = 0.0f;
        vertices[vertexIndex+1].pos[2] = (float)-size;

        vertices[vertexIndex+1].color[0] = 1.0f;
        vertices[vertexIndex+1].color[1] = 1.0f;
        vertices[vertexIndex+1].color[2] = 1.0f;
        vertices[vertexIndex+1].color[3] = 1.0f;

        vertexIndex += 2;
    }

    GLushort indices[numVertices];
    for (int i=0; i<numVertices; ++i) {
        indices[i] = i;
    }

    NFAssetSubset *pSubset = [[NFAssetSubset alloc] init];

    [pSubset allocateVerticesOfType:kVertexFormatDebug withNumVertices:numVertices];
    [pSubset loadVertexData:(void*)vertices ofType:kVertexFormatDebug withNumVertices:numVertices];

    [pSubset allocateIndicesWithNumElts:numVertices];
    [pSubset loadIndexData:indices ofSize:(numVertices * sizeof(GLushort))];

    self.subsetArray = @[(id)pSubset];
}

-(void) createAxisOfSize:(NSInteger)size {
    const NSInteger numVertices = 12;
    NFDebugVertex_t vertices[numVertices];
    memset(vertices, 0x00, numVertices * sizeof(NFDebugVertex_t));

    // x-axis (red)

    // pos x
    vertices[0].pos[0] = 0.0f;
    vertices[0].color[0] = 1.0f;
    vertices[0].color[3] = 1.0f;

    vertices[1].pos[0] = (float)size;
    vertices[1].color[0] = 1.0f;
    vertices[1].color[3] = 1.0f;

    // neg x
    vertices[2].pos[0] = (float)-size;
    vertices[2].color[0] = 0.25f;
    vertices[2].color[3] = 1.0f;

    vertices[3].pos[0] = 0.0f;
    vertices[3].color[0] = 0.25f;
    vertices[3].color[3] = 1.0f;

    // y-axis (green)

    // pos y
    vertices[4].pos[1] = 0.0f;
    vertices[4].color[1] = 1.0f;
    vertices[4].color[3] = 1.0f;

    vertices[5].pos[1] = (float)size;
    vertices[5].color[1] = 1.0f;
    vertices[5].color[3] = 1.0f;

    // neg y
    vertices[6].pos[1] = (float)-size;
    vertices[6].color[1] = 0.25f;
    vertices[6].color[3] = 1.0f;

    vertices[7].pos[1] = 0.0f;
    vertices[7].color[1] = 0.25f;
    vertices[7].color[3] = 1.0f;

    // z-axis (blue)

    // pos z
    vertices[8].pos[2] = 0.0f;
    vertices[8].color[2] = 1.0f;
    vertices[8].color[3] = 1.0f;

    vertices[9].pos[2] = (float)size;
    vertices[9].color[2] = 1.0f;
    vertices[9].color[3] = 1.0f;

    // neg z
    vertices[10].pos[2] = (float)-size;
    vertices[10].color[2] = 0.25f;
    vertices[10].color[3] = 1.0f;

    vertices[11].pos[2] = 0.0f;
    vertices[11].color[2] = 0.25f;
    vertices[11].color[3] = 1.0f;

    const NSInteger numIndices = 12;
    GLushort indices[numIndices];

    for (int i=0; i<numIndices; ++i) {
        indices[i] = i;
    }

    NFAssetSubset *pSubset = [[NFAssetSubset alloc] init];

    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    [pSubset allocateVerticesOfType:kVertexFormatDebug withNumVertices:numVertices];
    [pSubset loadVertexData:vertices ofType:kVertexFormatDebug withNumVertices:numVertices];

    self.subsetArray = @[(id)pSubset];
}

- (void) createPlaneOfSize:(NSInteger)size {
    const NSInteger numVertices = 4;
    NFVertex_t vertices[numVertices];

    // bottom left
    vertices[0].pos[0] = (float)-size;
    vertices[0].pos[1] = 0.0f;
    vertices[0].pos[2] = (float)-size;
    vertices[0].pos[3] = 1.0f;
    vertices[0].texCoord[0] = 0.0f;
    vertices[0].texCoord[1] = 0.0f;
    vertices[0].texCoord[2] = 0.0f;

    // bottom right
    vertices[1].pos[0] = (float)size;
    vertices[1].pos[1] = 0.0f;
    vertices[1].pos[2] = (float)-size;
    vertices[1].pos[3] = 1.0f;
    vertices[1].texCoord[0] = 1.0f * size;
    vertices[1].texCoord[1] = 0.0f;
    vertices[1].texCoord[2] = 0.0f;

    // top right
    vertices[2].pos[0] = (float)size;
    vertices[2].pos[1] = 0.0f;
    vertices[2].pos[2] = (float)size;
    vertices[2].pos[3] = 1.0f;
    vertices[2].texCoord[0] = 1.0f * size;
    vertices[2].texCoord[1] = 1.0f * size;
    vertices[2].texCoord[2] = 0.0f;

    // top left
    vertices[3].pos[0] = (float)-size;
    vertices[3].pos[1] = 0.0f;
    vertices[3].pos[2] = (float)size;
    vertices[3].pos[3] = 1.0f;
    vertices[3].texCoord[0] = 0.0f;
    vertices[3].texCoord[1] = 1.0f * size;
    vertices[3].texCoord[2] = 0.0f;

    const NSInteger numIndices = 6;
    GLushort indices[numIndices];

    //
    // TODO: should be able to handle either CCW or CW mode
    //
/*
    GLint frontFace;
    glGetIntegerv(GL_FRONT_FACE, &frontFace);
    if (frontFace == GL_CCW) {
        NSLog(@"glFrontFace currently set to CCW");
    }
    else if (frontFace == GL_CW) {
        NSLog(@"glFrontFace currently set to CW");
    }
    else {
        NSLog(@"unknown value returned");
    }
*/
    //
    // 0 1 2   2 3 0    CW
    // 2 1 0   0 3 2   CCW
    //

    indices[0] = 2;
    indices[1] = 1;
    indices[2] = 0;

    indices[3] = 0;
    indices[4] = 3;
    indices[5] = 2;

    NFFace_t face1 = [NFAssetUtils calculateFaceWithPoints:vertices withIndices:indices];

    GLushort *indexPtr = indices;
    indexPtr += 3;

    NFFace_t face2 = [NFAssetUtils calculateFaceWithPoints:vertices withIndices:indexPtr];

    // encode the faces into an array
    NSValue *value1 = [NSValue value:&face1 withObjCType:g_faceType];
    NSValue *value2 = [NSValue value:&face2 withObjCType:g_faceType];
    NSArray *array = @[value1, value2];

    for (int i=0; i<4; ++i) {
        GLKVector4 vertexNormal = [NFAssetUtils calculateAreaWeightedNormalOfIndex:i withFaces:array];
        vertices[i].norm[0] = vertexNormal.x;
        vertices[i].norm[1] = vertexNormal.y;
        vertices[i].norm[2] = vertexNormal.z;
        vertices[i].norm[3] = vertexNormal.w;
    }

    NFAssetSubset *pSubset = [[NFAssetSubset alloc] init];

    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    [pSubset allocateVerticesOfType:kVertexFormatDefault withNumVertices:numVertices];
    [pSubset loadVertexData:vertices ofType:kVertexFormatDefault withNumVertices:numVertices];

    self.subsetArray = @[(id)pSubset];
}

- (void) createCubeMapGeometryOfSize:(NSInteger)size {
    const NSInteger numVertices = 36;
    NFVertex_t vertices[numVertices];

    memset(vertices, 0x00, numVertices * sizeof(NFVertex_t));

    vertices[0].pos[0] = -1.0f;     vertices[0].pos[1] = 1.0f;      vertices[0].pos[2] = -1.0f;
    vertices[1].pos[0] = -1.0f;     vertices[1].pos[1] = -1.0f;     vertices[1].pos[2] = -1.0f;
    vertices[2].pos[0] = 1.0f;      vertices[2].pos[1] = -1.0f;     vertices[2].pos[2] = -1.0f;
    vertices[3].pos[0] = 1.0f;      vertices[3].pos[1] = -1.0f;     vertices[3].pos[2] = -1.0f;
    vertices[4].pos[0] = 1.0f;      vertices[4].pos[1] = 1.0f;      vertices[4].pos[2] = -1.0f;
    vertices[5].pos[0] = -1.0f;     vertices[5].pos[1] = 1.0f;      vertices[5].pos[2] = -1.0f;

    vertices[6].pos[0] = -1.0f;     vertices[6].pos[1] = -1.0f;     vertices[6].pos[2] = 1.0f;
    vertices[7].pos[0] = -1.0f;     vertices[7].pos[1] = -1.0f;     vertices[7].pos[2] = -1.0f;
    vertices[8].pos[0] = -1.0f;     vertices[8].pos[1] = 1.0f;      vertices[8].pos[2] = -1.0f;
    vertices[9].pos[0] = -1.0f;     vertices[9].pos[1] = 1.0f;      vertices[9].pos[2] = -1.0f;
    vertices[10].pos[0] = -1.0f;    vertices[10].pos[1] = 1.0f;     vertices[10].pos[2] = 1.0f;
    vertices[11].pos[0] = -1.0f;    vertices[11].pos[1] = -1.0f;    vertices[11].pos[2] = 1.0f;

    vertices[12].pos[0] = 1.0f;     vertices[12].pos[1] = -1.0f;    vertices[12].pos[2] = -1.0f;
    vertices[13].pos[0] = 1.0f;     vertices[13].pos[1] = -1.0f;    vertices[13].pos[2] = 1.0f;
    vertices[14].pos[0] = 1.0f;     vertices[14].pos[1] = 1.0f;     vertices[14].pos[2] = 1.0f;
    vertices[15].pos[0] = 1.0f;     vertices[15].pos[1] = 1.0f;     vertices[15].pos[2] = 1.0f;
    vertices[16].pos[0] = 1.0f;     vertices[16].pos[1] = 1.0f;     vertices[16].pos[2] = -1.0f;
    vertices[17].pos[0] = 1.0f;     vertices[17].pos[1] = -1.0f;    vertices[17].pos[2] = -1.0f;

    vertices[18].pos[0] = -1.0f;    vertices[18].pos[1] = -1.0f;    vertices[18].pos[2] = 1.0f;
    vertices[19].pos[0] = -1.0f;    vertices[19].pos[1] = 1.0f;     vertices[19].pos[2] = 1.0f;
    vertices[20].pos[0] = 1.0f;     vertices[20].pos[1] = 1.0f;     vertices[20].pos[2] = 1.0f;
    vertices[21].pos[0] = 1.0f;     vertices[21].pos[1] = 1.0f;     vertices[21].pos[2] = 1.0f;
    vertices[22].pos[0] = 1.0f;     vertices[22].pos[1] = -1.0f;    vertices[22].pos[2] = 1.0f;
    vertices[23].pos[0] = -1.0f;    vertices[23].pos[1] = -1.0f;    vertices[23].pos[2] = 1.0f;

    vertices[24].pos[0] = -1.0f;    vertices[24].pos[1] = 1.0f;     vertices[24].pos[2] = -1.0f;
    vertices[25].pos[0] = 1.0f;     vertices[25].pos[1] = 1.0f;     vertices[25].pos[2] = -1.0f;
    vertices[26].pos[0] = 1.0f;     vertices[26].pos[1] = 1.0f;     vertices[26].pos[2] = 1.0f;
    vertices[27].pos[0] = 1.0f;     vertices[27].pos[1] = 1.0f;     vertices[27].pos[2] = 1.0f;
    vertices[28].pos[0] = -1.0f;    vertices[28].pos[1] = 1.0f;     vertices[28].pos[2] = 1.0f;
    vertices[29].pos[0] = -1.0f;    vertices[29].pos[1] = 1.0f;     vertices[29].pos[2] = -1.0f;

    vertices[30].pos[0] = -1.0f;    vertices[30].pos[1] = -1.0f;    vertices[30].pos[2] = -1.0f;
    vertices[31].pos[0] = -1.0f;    vertices[31].pos[1] = -1.0f;    vertices[31].pos[2] = 1.0f;
    vertices[32].pos[0] = 1.0f;     vertices[32].pos[1] = -1.0f;    vertices[32].pos[2] = -1.0f;
    vertices[33].pos[0] = 1.0f;     vertices[33].pos[1] = -1.0f;    vertices[33].pos[2] = -1.0f;
    vertices[34].pos[0] = -1.0f;    vertices[34].pos[1] = -1.0f;    vertices[34].pos[2] = 1.0f;
    vertices[35].pos[0] = 1.0f;     vertices[35].pos[1] = -1.0f;    vertices[35].pos[2] = 1.0f;


    const NSInteger numIndices = 6;
    GLushort indices[numIndices];

    //
    // TODO: update drawing of cube map to use indices
    //
    memset(indices, 0x00, numIndices * sizeof(GLushort));

    NFAssetSubset *pSubset = [[NFAssetSubset alloc] init];

    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    [pSubset allocateVerticesOfType:kVertexFormatDefault withNumVertices:numVertices];
    [pSubset loadVertexData:vertices ofType:kVertexFormatDefault withNumVertices:numVertices];

    self.subsetArray = @[(id)pSubset];
}

- (void) createUVSphereWithRadius:(float)radius withStacks:(int)stacks withSlices:(int)slices withVertexFormat:(NF_VERTEX_FORMAT)vertexFormat {
    const NSInteger numVertices = (stacks+1) * (slices+1) + 1;
    const NSInteger numIndices = stacks * slices * 3 * 2;

    NFAssetSubset *pSubset = [[NFAssetSubset alloc] init];

    // spherical coordinates as mapped to perspective coordiantes (x to the right, y up, +z towards the camera)
    // x = r * sin(phi) * sin(theta);
    // y = r * cos(phi);
    // z = r * sin(phi) * cos(theta);
    // phi   => [0, M_PI]    inclination (vertical angle)
    // theta => [0, 2*M_PI]  azimuth (horizontal angle)

    float phi = 0.0f;
    float theta = 0.0f;
    float phiDelta = M_PI / (float)stacks;
    float thetaDelta = (2 * M_PI) / (float)slices;

    if (vertexFormat == kVertexFormatDefault) {
        NFVertex_t vertices[numVertices];

        // NOTE: need to add an extra slice to get a coincident vertex with tex coord S = 0.0 through 1.0, and
        //       and adding an extra stack to get the bottom point i.e. would take five vertical vertices to
        //       make four stacks
        int index=0;
        for (NSInteger i=0; i<stacks+1; ++i) {
            for (NSInteger j=0; j<slices+1; ++j) {

                //
                // TODO: update create sphere method to use vectors and quaternions for generating vertices
                //
                vertices[index].pos[0] = radius * sin(phi) * sin(theta);
                vertices[index].pos[1] = radius * cos(phi);
                vertices[index].pos[2] = radius * sin(phi) * cos(theta);
                vertices[index].pos[3] = 1.0f;

                //
                // TODO: second to last vertex on the top and bottom cap won't get used
                //       should ideally generate one less top and bottom vertex and evenly
                //       distribute the texture coordinates
                //

                //
                // TODO: calculate a more accurate texture coordinate for spherical texture mapping
                //

                vertices[index].texCoord[0] = phi / M_PI;
                vertices[index].texCoord[1] = theta / (2.0f*M_PI);
                vertices[index].texCoord[2] = 0.0f;

                GLKVector3 normal = GLKVector3Make(vertices[index].pos[0], vertices[index].pos[1], vertices[index].pos[2]);
                normal = GLKVector3Normalize(normal);

                vertices[index].norm[0] = normal.x;
                vertices[index].norm[1] = normal.y;
                vertices[index].norm[2] = normal.z;
                vertices[index].norm[3] = 0.0f;

                theta += thetaDelta;
                ++index;
            }
            
            phi += phiDelta;
            theta = 0.0f;
        }
        
        [pSubset allocateVerticesOfType:kVertexFormatDefault withNumVertices:numVertices];
        [pSubset loadVertexData:vertices ofType:kVertexFormatDefault withNumVertices:numVertices];
    }
    else if (vertexFormat == kVertexFormatDebug) {
        NFDebugVertex_t vertices[numVertices];

        int index=0;
        for (NSInteger i=0; i<stacks+1; ++i) {
            for (NSInteger j=0; j<slices+1; ++j) {
                vertices[index].pos[0] = radius * sin(phi) * sin(theta);
                vertices[index].pos[1] = radius * cos(phi);
                vertices[index].pos[2] = radius * sin(phi) * cos(theta);

                GLKVector3 normal = GLKVector3Make(vertices[index].pos[0], vertices[index].pos[1], vertices[index].pos[2]);
                normal = GLKVector3Normalize(normal);

                vertices[index].norm[0] = normal.x;
                vertices[index].norm[1] = normal.y;
                vertices[index].norm[2] = normal.z;

                vertices[index].color[0] = 1.0f;
                vertices[index].color[1] = 1.0f;
                vertices[index].color[2] = 1.0f;
                vertices[index].color[3] = 1.0f;

                theta += thetaDelta;
                ++index;
            }

            phi += phiDelta;
            theta = 0.0f;
        }

        [pSubset allocateVerticesOfType:kVertexFormatDebug withNumVertices:numVertices];
        [pSubset loadVertexData:vertices ofType:kVertexFormatDebug withNumVertices:numVertices];
    }
    else {
        NSLog(@"WARNING: createUVSphere received unrecongized vertex format, asset will not have valid vertices or indices");
        return;
    }

    // index the first stack
    GLushort indices[numIndices];
    int index = 0;
    for (int i=0; i<slices-1; ++i) {
        indices[index] = i;
        indices[index+1] = i + slices + 1;
        indices[index+2] = i + slices + 2;
        index += 3;
    }
    indices[index] = slices;
    indices[index+1] = 2*slices;
    indices[index+2] = 2*slices + 1;
    index += 3;

    // index all stacks up to the bottom one
    GLushort p0 = slices+1;
    GLushort p1 = p0 + slices+1;
    GLushort p2 = p1 + 1;
    GLushort p3 = p0 + 1;
    for (int i=0; i<stacks-2; ++i) {
        for (int j=0; j<slices; ++j) {
            indices[index] = p0;
            indices[index+1] = p1;
            indices[index+2] = p2;
            index += 3;

            indices[index] = p0;
            indices[index+1] = p2;
            indices[index+2] = p3;
            index += 3;

            ++p0;
            ++p1;
            ++p2;
            ++p3;
        }

        GLushort sliceInc = (i+2) * (slices+1);
        p0 = sliceInc;
        p1 = p0 + slices+1;
        p2 = p1 + 1;
        p3 = p0 + 1;
    }

    // index bottom stack
    p0 = (slices+1) * (stacks-1);
    p1 = (slices+1) * stacks;
    p2 = p0 + 1;
    for (int i=0; i<slices-1; ++i) {
        indices[index] = p0;
        indices[index+1] = p1;
        indices[index+2] = p2;

        ++p0;
        ++p1;
        ++p2;
        index += 3;
    }
    indices[index] = p0;
    indices[index+1] = p1+1;
    indices[index+2] = p2;

    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    self.subsetArray = @[(id)pSubset];
}

- (void) createCylinderWithRadius:(float)radius ofHeight:(float)height withSlices:(NSInteger)slices withVertexFormat:(NF_VERTEX_FORMAT)vertexFormat {
    NSAssert(powerof2(slices) && slices >= 8, @"slices must be a power of 2 and at least equal to 8");

    const NSInteger numVertices = 6 * slices;
    const NSInteger numIndices = 12 * slices;

    NFAssetSubset *pSubset = [[NFAssetSubset alloc] init];

    // NOTE: creating and setting up the indices first so they can be used to generate normals
    //       if using the default vertex format
    GLushort indices[numIndices];

    GLushort idxVal[6];
    for (int i=0; i<6; ++i) {
        idxVal[i] = (GLushort)i;
    }

    int idx = 0;
    for (int i=0; i<slices; ++i) {
        // top of the cylinder
        indices[idx]   = idxVal[0];
        indices[idx+1] = idxVal[2];
        indices[idx+2] = idxVal[1];
        idx += 3;

        // first triangle of side
        indices[idx]   = idxVal[2];
        indices[idx+1] = idxVal[4];
        indices[idx+2] = idxVal[1];
        idx += 3;

        // second triangle of side
        indices[idx]   = idxVal[5];
        indices[idx+1] = idxVal[4];
        indices[idx+2] = idxVal[2];
        idx += 3;

        // bottom of the cylinder
        indices[idx]   = idxVal[4];
        indices[idx+1] = idxVal[5];
        indices[idx+2] = idxVal[3];
        idx += 3;

        for (int j=0; j<6; ++j) {
            idxVal[j] += 6;
        }
    }

    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    //
    // TODO: need to adjust the length of the vectors to be equal to the radius of the cylinder
    //

    GLKVector3 vecs[3];
    vecs[0] = GLKVector3Make(0.0f, 0.0f, 0.0f);
    vecs[1] = GLKVector3Make(1.0f, 0.0f, 0.0f);
    vecs[2] = vecs[1];

    NSInteger slicesPerQuad = slices / 4;
    GLKQuaternion quat = GLKQuaternionMakeWithAngleAndAxis(-1.0f * M_PI / (float)(slicesPerQuad*2), 0.0f, 1.0f, 0.0f);


    //
    // TODO: the following should be faster than v' = q * v * conjugate(q) i.e. GLKQuaternionRotateVector3 impl
    //       (was it inverse(q) ???)
    //
    // t = 2 * cross(q.xyz, v)
    // v' = v + q.w * t + cross(q.wyz, t)


    if (vertexFormat == kVertexFormatDefault) {
        NFVertex_t vertices[numVertices];

        float uTexCoord = 0.0f;
        float deltaU = 1.0f/(float)slices;

        float surfaceDist = (2.0f * radius) + height;

        float vTexCoords[4];
        vTexCoords[0] = 0.0f;
        vTexCoords[1] = radius / surfaceDist;
        vTexCoords[2] = (radius+height) / surfaceDist;
        vTexCoords[3] = 1.0f;

        int vertIndex = 0;
        for (int i=0; i<slices; ++i) {
            vecs[1] = vecs[2];
            vecs[2] = GLKVector3Normalize(GLKQuaternionRotateVector3(quat, vecs[2]));

            // top triangle
            for (int j=0; j<3; ++j) {
                vertices[vertIndex].pos[0] = vecs[j].x;
                vertices[vertIndex].pos[1] = height/2.0;
                vertices[vertIndex].pos[2] = vecs[j].z;
                vertices[vertIndex].pos[3] = 1.0f;

                vertices[vertIndex].texCoord[0] = uTexCoord;
                vertices[vertIndex].texCoord[1] = (j!=0) ? vTexCoords[1] : vTexCoords[0];
                vertices[vertIndex].texCoord[2] = 0.0f;

                ++vertIndex;
            }

            // bottom triangle
            for (int j=0; j<3; ++j) {
                vertices[vertIndex].pos[0] = vecs[j].x;
                vertices[vertIndex].pos[1] = -height/2.0;
                vertices[vertIndex].pos[2] = vecs[j].z;
                vertices[vertIndex].pos[3] = 1.0f;

                vertices[vertIndex].texCoord[0] = uTexCoord;
                vertices[vertIndex].texCoord[1] = (j!=0) ? vTexCoords[2] : vTexCoords[3];
                vertices[vertIndex].texCoord[2] = 0.0f;

                ++vertIndex;
            }

            uTexCoord += deltaU;
        }

        // build faces array and calculate normals
        GLushort* indexPtr = indices;
        NSMutableArray* faceArray = [[NSMutableArray alloc] init];

        for (int i=0; i<numIndices/3; ++i) {
            NFFace_t face = [NFAssetUtils calculateFaceWithPoints:vertices withIndices:indexPtr];
            NSValue *value = [NSValue value:&face withObjCType:g_faceType];
            [faceArray addObject:value];
            indexPtr += 3;
        }

        for (int i=0; i<numVertices; ++i) {

            //
            // TODO: the normals do not make for as smooth of a cylinder as expected, try hand calculating a few normals
            //       and then compare to NF asset utils generation
            //

            GLKVector4 vertexNormal = [NFAssetUtils calculateAreaWeightedNormalOfIndex:(GLushort)i withFaces:faceArray];
            vertices[i].norm[0] = vertexNormal.x;
            vertices[i].norm[1] = vertexNormal.y;
            vertices[i].norm[2] = vertexNormal.z;
            vertices[i].norm[3] = vertexNormal.w;
        }

        [pSubset allocateVerticesOfType:kVertexFormatDefault withNumVertices:numVertices];
        [pSubset loadVertexData:vertices ofType:kVertexFormatDefault withNumVertices:numVertices];
    }
    else if (vertexFormat == kVertexFormatDebug) {
        NFDebugVertex_t vertices[numVertices];

        for (int i=0; i<numVertices; ++i) {
            vertices[i].color[0] = 1.0f;
            vertices[i].color[1] = 1.0f;
            vertices[i].color[2] = 1.0f;
            vertices[i].color[3] = 1.0f;
        }

        int vertIndex = 0;
        for (int i=0; i<slices; ++i) {
            vecs[1] = vecs[2];
            vecs[2] = GLKVector3Normalize(GLKQuaternionRotateVector3(quat, vecs[2]));

            // top triangle
            for (int j=0; j<3; ++j) {
                vertices[vertIndex].pos[0] = vecs[j].x;
                vertices[vertIndex].pos[1] = height/2.0;
                vertices[vertIndex].pos[2] = vecs[j].z;
                ++vertIndex;
            }

            // bottom triangle
            for (int j=0; j<3; ++j) {
                vertices[vertIndex].pos[0] = vecs[j].x;
                vertices[vertIndex].pos[1] = -height/2.0;
                vertices[vertIndex].pos[2] = vecs[j].z;

                ++vertIndex;
            }
        }

        [pSubset allocateVerticesOfType:kVertexFormatDebug withNumVertices:numVertices];
        [pSubset loadVertexData:vertices ofType:kVertexFormatDebug withNumVertices:numVertices];
    }

    self.subsetArray = @[(id)pSubset];
}

- (void) createConeWithRadius:(float)radius ofHeight:(float)height withSlices:(NSInteger)slices withVertexFormat:(NF_VERTEX_FORMAT)vertexFormat {
    NSAssert(powerof2(slices) && slices >= 8, @"slices must be a power of 2 and at least equal to 8");

    const NSInteger numVertices = 3 * (slices+1);
    const NSInteger numIndices = 6 * slices;

    NFAssetSubset *pSubset = [[NFAssetSubset alloc] init];

    GLushort indices[numIndices];

    GLushort idxVal[4];
    for (int i=0; i<4; ++i) {
        idxVal[i] = (GLushort)i;
    }

    // indexing order
    idxVal[0] = 0; // top
    idxVal[1] = 4; // left
    idxVal[2] = 1; // right
    idxVal[3] = 2; // bottom

    int idx = 0;
    for (int i=0; i<slices; ++i) {
        // top triangle
        indices[idx]   = idxVal[0];
        indices[idx+1] = idxVal[1];
        indices[idx+2] = idxVal[2];
        idx += 3;

        // bottom triangle
        indices[idx]   = idxVal[2];
        indices[idx+1] = idxVal[1];
        indices[idx+2] = idxVal[3];
        idx += 3;

        for (int j=0; j<4; ++j) {
            idxVal[j] += 3;
        }
    }

    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    NSInteger slicesPerQuad = slices / 4;
    GLKQuaternion quat = GLKQuaternionMakeWithAngleAndAxis(-1.0f * M_PI / (float)(slicesPerQuad*2), 0.0f, 1.0f, 0.0f);

    //
    // TODO: scale vectors to radius length
    //

    GLKVector3 vecs[3];
    vecs[0] = GLKVector3Make(0.0f, height, 0.0f);
    vecs[1] = GLKVector3Make(1.0f, 0.0f, 0.0f);
    vecs[2] = GLKVector3Make(0.0f, 0.0f, 0.0f);

    if (vertexFormat == kVertexFormatDefault) {
        NFVertex_t vertices[numVertices];

        float uTexCoord = 0.0f;
        float deltaU = 1.0f/(float)slices;
        float vTexCoords[3];

        GLKVector3 diff = GLKVector3Subtract(vecs[0], vecs[1]);
        float diffLength = GLKVector3Length(diff);

        vTexCoords[0] = 0.0f;
        vTexCoords[1] = diffLength / (diffLength + radius);
        vTexCoords[2] = 1.0f;

        int vertIndex = 0;
        for (int i=0; i<slices+1; ++i) {

            for (int j=0; j<3; ++j) {
                vertices[vertIndex].pos[0] = vecs[j].x;
                vertices[vertIndex].pos[1] = vecs[j].y;
                vertices[vertIndex].pos[2] = vecs[j].z;
                vertices[vertIndex].pos[3] = 1.0f;

                vertices[vertIndex].texCoord[0] = uTexCoord;
                vertices[vertIndex].texCoord[1] = vTexCoords[j];
                vertices[vertIndex].texCoord[2] = 0.0f;

                ++vertIndex;
            }

            vecs[1] = GLKVector3Normalize(GLKQuaternionRotateVector3(quat, vecs[1]));
            uTexCoord += deltaU;
        }

        // build faces array and calculate normals
        GLushort* indexPtr = indices;
        NSMutableArray* faceArray = [[NSMutableArray alloc] init];

        for (int i=0; i<numIndices/3; ++i) {
            NFFace_t face = [NFAssetUtils calculateFaceWithPoints:vertices withIndices:indexPtr];
            NSValue *value = [NSValue value:&face withObjCType:g_faceType];
            [faceArray addObject:value];
            indexPtr += 3;
        }

        for (int i=0; i<numVertices; ++i) {

            //
            // TODO: the normals do not make for as smooth of a cone as expected, try hand calculating a few normals
            //       and then compare to NF asset utils generation
            //

            GLKVector4 vertexNormal = [NFAssetUtils calculateAreaWeightedNormalOfIndex:(GLushort)i withFaces:faceArray];
            vertices[i].norm[0] = vertexNormal.x;
            vertices[i].norm[1] = vertexNormal.y;
            vertices[i].norm[2] = vertexNormal.z;
            vertices[i].norm[3] = vertexNormal.w;
        }

        
        [pSubset allocateVerticesOfType:kVertexFormatDefault withNumVertices:numVertices];
        [pSubset loadVertexData:vertices ofType:kVertexFormatDefault withNumVertices:numVertices];
    }
    else if (vertexFormat == kVertexFormatDebug) {
        NFDebugVertex_t vertices[numVertices];

        int vertIndex = 0;
        for (int i=0; i<slices+1; ++i) {

            for (int j=0; j<3; ++j) {
                vertices[vertIndex].pos[0] = vecs[j].x;
                vertices[vertIndex].pos[1] = vecs[j].y;
                vertices[vertIndex].pos[2] = vecs[j].z;

                vertices[vertIndex].color[0] = 1.0f;
                vertices[vertIndex].color[1] = 1.0f;
                vertices[vertIndex].color[2] = 1.0f;
                vertices[vertIndex].color[3] = 1.0f;

                ++vertIndex;
            }

            vecs[1] = GLKVector3Normalize(GLKQuaternionRotateVector3(quat, vecs[1]));
        }

        [pSubset allocateVerticesOfType:kVertexFormatDebug withNumVertices:numVertices];
        [pSubset loadVertexData:vertices ofType:kVertexFormatDebug withNumVertices:numVertices];
    }

    self.subsetArray = @[(id)pSubset];
}

@end
