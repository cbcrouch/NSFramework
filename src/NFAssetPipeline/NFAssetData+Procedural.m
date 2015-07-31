//
//  NFAssetData+Procedural.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
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

    NFAssetSubset *pSubset = [[[NFAssetSubset alloc] init] autorelease];

    [pSubset allocateVerticesOfType:kVertexFormatDebug withNumVertices:numVertices];
    [pSubset loadVertexData:(void*)vertices ofType:kVertexFormatDebug withNumVertices:numVertices];

    [pSubset allocateIndicesWithNumElts:numVertices];
    [pSubset loadIndexData:indices ofSize:(numVertices * sizeof(GLushort))];

    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
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

    NFAssetSubset *pSubset = [[[NFAssetSubset alloc] init] autorelease];

    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    [pSubset allocateVerticesOfType:kVertexFormatDebug withNumVertices:numVertices];
    [pSubset loadVertexData:vertices ofType:kVertexFormatDebug withNumVertices:numVertices];

    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
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
    NSArray *array = [[[NSArray alloc] initWithObjects:value1, value2, nil] autorelease];

    for (int i=0; i<4; ++i) {
        GLKVector4 vertexNormal = [NFAssetUtils calculateAreaWeightedNormalOfIndex:i withFaces:array];
        vertices[i].norm[0] = vertexNormal.x;
        vertices[i].norm[1] = vertexNormal.y;
        vertices[i].norm[2] = vertexNormal.z;
        vertices[i].norm[3] = vertexNormal.w;
    }

    NFAssetSubset *pSubset = [[[NFAssetSubset alloc] init] autorelease];

    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    [pSubset allocateVerticesOfType:kVertexFormatDefault withNumVertices:numVertices];
    [pSubset loadVertexData:vertices ofType:kVertexFormatDefault withNumVertices:numVertices];

    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

- (void) createUVSphereWithRadius:(float)radius withStacks:(int)stacks withSlices:(int)slices withVertexFormat:(NF_VERTEX_FORMAT)vertexFormat {
    const NSInteger numVertices = (stacks+1) * (slices+1) + 1;
    const NSInteger numIndices = stacks * slices * 3 * 2;

    NFAssetSubset *pSubset = [[[NFAssetSubset alloc] init] autorelease];

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
                vertices[index].pos[0] = radius * sin(phi) * sin(theta);
                vertices[index].pos[1] = radius * cos(phi);
                vertices[index].pos[2] = radius * sin(phi) * cos(theta);
                vertices[index].pos[3] = 1.0f;

                //
                // TODO: second to last vertex on the top and bottom cap won't get used
                //       should ideally generate one less top and bottom vertex and evenly
                //       distribute the texture coordinates
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

    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

- (void) createCylinder:(float)radius ofHeight:(float)height withVertexFormat:(NF_VERTEX_FORMAT)vertexFormat {

    //
    //
    //
    //const NSInteger numVertices = 6;
    const NSInteger numVertices = 6*2;

    //const NSInteger numIndices = 12*2;

    const NSInteger numIndices = 18;


    NFAssetSubset *pSubset = [[[NFAssetSubset alloc] init] autorelease];

    NFDebugVertex_t vertices[numVertices];

    for (int i=0; i<numVertices; ++i) {
        vertices[i].color[0] = 1.0f;
        vertices[i].color[1] = 1.0f;
        vertices[i].color[2] = 1.0f;
        vertices[i].color[3] = 1.0f;
    }


    uint32_t slices = 32;

    // 8 slices should result in a 45 degree v3 vector
    // 16 slices => 22.5 degree v3 vector
    // 32 slices => 11.25 degree v3 vector

    // 8 / 4 = 2 points per quadrant => 45 degree v3 vector which needs 1 iteration
    // 16 / 4 = 4 points per quadrant => 22.5 degree v3 vector which needs 2 iterations
    // 32 / 4 = 8 points per quadrant => 11.25 degree v3 vector which needs 3 iterations


    NSAssert(powerof2(slices) && slices > 4, @"slices must be a power of 2 and at least equal to 8");


    //
    // TODO: build a fast (non x86) integer log2 algorithm (lookup table ??)
    //

    uint32_t x = (slices >> 2); // divide slices by 4
    uint32_t y;
    __asm ( "\tbsr %1, %0\n" // return position of highest set bit (bit scan reverse)
           : "=r"(y)
           : "r" (x)
           );

    NSLog(@"y = %d", y);


    uint32_t iterations = (uint32_t)log2(slices / 4.0);

    NSLog(@"n = %d", iterations);



    //height /= 2.0f;

    GLKVector3 v0 = GLKVector3Make(0.0f, 0.0f, 0.0f);
    GLKVector3 v1 = GLKVector3Make(1.0f, 0.0f, 0.0f);
    GLKVector3 v2 = GLKVector3Make(0.0f, 0.0f, 1.0f);

    GLKVector3 v3 = GLKVector3Add(v1, v2); // 45 degree vector
    v3 = GLKVector3Normalize(v3);

    v3 = GLKVector3Normalize(GLKVector3Add(v1, v3)); // 22.5 degree vector


    //
    // TODO: will need coincident vertices for center the cylinder
    //
    vertices[0].pos[0] = v0.x;
    vertices[0].pos[1] = height;
    vertices[0].pos[2] = v0.z;

    vertices[1].pos[0] = v1.x;
    vertices[1].pos[1] = height;
    vertices[1].pos[2] = v1.z;

    vertices[2].pos[0] = v3.x;
    vertices[2].pos[1] = height;
    vertices[2].pos[2] = v3.z;




    vertices[6].pos[0] = v0.x;
    vertices[6].pos[1] = height/2.0;
    vertices[6].pos[2] = v0.z;

    vertices[7].pos[0] = v1.x;
    vertices[7].pos[1] = height/2.0;
    vertices[7].pos[2] = v1.z;

    vertices[8].pos[0] = v3.x;
    vertices[8].pos[1] = height/2.0;
    vertices[8].pos[2] = v3.z;





    v3 = GLKVector3Add(v1, v2);
    v3 = GLKVector3Normalize(v3);

    vertices[3].pos[0] = v3.x;
    vertices[3].pos[1] = height;
    vertices[3].pos[2] = v3.z;



    vertices[9].pos[0] = v3.x;
    vertices[9].pos[1] = height/2.0;
    vertices[9].pos[2] = v3.z;





    v3 = GLKVector3Add(v3, v2);
    v3 = GLKVector3Normalize(v3);

    vertices[4].pos[0] = v3.x;
    vertices[4].pos[1] = height;
    vertices[4].pos[2] = v3.z;


    vertices[10].pos[0] = v3.x;
    vertices[10].pos[1] = height;
    vertices[10].pos[2] = v3.z;





    vertices[5].pos[0] = v2.x;
    vertices[5].pos[1] = height;
    vertices[5].pos[2] = v2.z;



    vertices[11].pos[0] = v2.x;
    vertices[11].pos[1] = height;
    vertices[11].pos[2] = v2.z;



    [pSubset allocateVerticesOfType:kVertexFormatDebug withNumVertices:numVertices];
    [pSubset loadVertexData:vertices ofType:kVertexFormatDebug withNumVertices:numVertices];


    GLushort indices[numIndices];

    memset(indices, 0, numIndices * sizeof(GLushort));


    //

    indices[0] = 0;
    indices[1] = 2;
    indices[2] = 1;

    indices[3] = 0;
    indices[4] = 3;
    indices[5] = 2;

    indices[6] = 0;
    indices[7] = 4;
    indices[8] = 3;

    indices[9] = 0;
    indices[10] = 5;
    indices[11] = 4;



    indices[12] = 2;
    indices[13] = 7;
    indices[14] = 1;

    indices[15] = 2;
    indices[16] = 8;
    indices[17] = 7;



    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

- (void) createCone:(float)radius ofHeight:(float)height withVertexFormat:(NF_VERTEX_FORMAT)vertexFormat {
    //
    // TODO: implement
    //
}

@end
