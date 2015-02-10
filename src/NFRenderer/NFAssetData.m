//
//  NSAssetData.m
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"
#import "NFRenderer.h"
#import "NFRUtils.h"

//
// TODO: find out who is including gl.h into the project (might be the display link...), one way around all this
//       might be to skip the provided OpenGL header file and use a custom loader
//

// NOTE: because both gl.h and gl3.h are included will get symbols for deprecated GL functions
//       and they should absolutely not be used
#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>
#import <GLKit/GLKit.h>


//
// TODO: need to make a comprehensive collection of state objects that are bundled together
//       into a parent pipeline object
//
typedef struct NFVertState_t {
    GLint vertAttrib;
    GLint normAttrib;
    GLint texAttrib;
} NFVertState_t;


@interface NFSubset()


//
// TODO: will need to integrate the min/max dimension finding into the NFAssetData containing object
//       and keep the subsets transforms relative
//

//
// TODO: should store the min/max dimensions of the complete asset as well as the subset
//       also each subset should have a centering transform and unit scaling transform
//       (moving through transform hierarchy will store relative transformations but will
//       possibly need to use the unit scaling and centering transforms)
//
@property (nonatomic, assign) GLKVector3 minDimensions;
@property (nonatomic, assign) GLKVector3 maxDimensions;


@property (nonatomic, assign) NFVertex_t *vertices;
@property (nonatomic, assign) GLushort *indices;
@property (nonatomic, assign) NSInteger numVertices;
@property (nonatomic, assign) NSInteger numIndices;

@property (nonatomic, assign) GLuint hVBO;
@property (nonatomic, assign) GLuint hEBO;
@property (nonatomic, assign) GLenum mode;

- (void) loadResourcesWithVertexState:(NFVertState_t)state;
- (void) drawWithVertexState:(NFVertState_t)state withProgram:(GLuint)hProgram withModelUniform:(GLuint)modelLoc;

//
// TODO: rename something like calcUnitLengthTransform and add a calcBoundingBox method
//
- (void) calcCenterPointTransform;

@end

@implementation NFSubset

@synthesize unitScalarMatrix = _unitScalarMatrix;
@synthesize originCenterMatrix = _originCenterMatrix;

@synthesize minDimensions = _minDimensions;
@synthesize maxDimensions = _maxDimensions;

@synthesize drawMode = _drawMode;
@synthesize modelMat = _modelMat;
@synthesize surfaceModel = _surfaceModel;

@synthesize vertices = _vertices;
@synthesize indices = _indices;
@synthesize numVertices = _numVertices;
@synthesize numIndices = _numIndices;

@synthesize hVBO = _hVBO;
@synthesize hEBO = _hEBO;
@synthesize mode = _mode;

- (instancetype) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    [self setDrawMode:kDrawTriangles];
    [self setModelMat:GLKMatrix4Identity];

    [self setVertices:NULL];
    [self setIndices:NULL];
    [self setNumVertices:0];
    [self setNumIndices:0];

    [self setMode:GL_TRIANGLES];

    return self;
}

- (void) dealloc {
    if (self.vertices != NULL) { free(self.vertices); }
    if (self.indices != NULL) { free(self.indices); }
    [super dealloc];
}

- (void) setDrawMode:(DRAWING_MODE)drawMode {

    // all OpenGL modes
    //GL_POINTS, GL_LINE_STRIP, GL_LINE_LOOP, GL_LINES, GL_LINE_STRIP_ADJACENCY, GL_LINES_ADJACENCY
    //GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_TRIANGLES, GL_TRIANGLE_STRIP_ADJACENCY, GL_TRIANGLES_ADJACENCY
    //GL_PATCHES

    _drawMode = drawMode;
    switch (_drawMode) {
        case kDrawLineStrip: self.mode = GL_LINE_STRIP; break;
        case kDrawLineLoop: self.mode = GL_LINE_LOOP; break;
        case kDrawLines: self.mode = GL_LINES; break;

        case kDrawTriangleStrip: self.mode = GL_TRIANGLE_STRIP; break;
        case kDrawTriangleFan: self.mode = GL_TRIANGLE_FAN; break;
        case kDrawTriangles: self.mode = GL_TRIANGLES; break;

        default:
            NSAssert(false, @"ERROR: setDrawMode received unknown type");
            break;
    }
}

- (void) allocateVerticesWithNumElts:(NSUInteger)num {
    self.vertices = (NFVertex_t *)malloc(num * sizeof(NFVertex_t));
    NSAssert(self.vertices != NULL, @"failed to allocate interleaved vertices");
    self.numVertices = (NSInteger)num;
}

- (void) allocateIndicesWithNumElts:(NSUInteger)num {
    self.indices = (GLushort *)malloc(num * sizeof(GLushort));
    NSAssert(self.indices != NULL, @"failed to allocate index array");
    self.numIndices = (NSInteger)num;
}

- (void) calcSubsetBounds {
    float min_x, max_x;
    float min_y, max_y;
    float min_z, max_z;

    min_x = max_x = self.vertices->pos[0];
    min_y = max_y = self.vertices->pos[1];
    min_z = max_z = self.vertices->pos[2];

    for (NSInteger i = 0; i < self.numVertices; ++i) {
        if (self.vertices[i].pos[0] < min_x) { min_x = self.vertices[i].pos[0]; }
        if (self.vertices[i].pos[0] > max_x) { max_x = self.vertices[i].pos[0]; }
        if (self.vertices[i].pos[1] < min_y) { min_y = self.vertices[i].pos[1]; }
        if (self.vertices[i].pos[1] > max_y) { max_y = self.vertices[i].pos[1]; }
        if (self.vertices[i].pos[2] < min_z) { min_z = self.vertices[i].pos[2]; }
        if (self.vertices[i].pos[2] > max_z) { max_z = self.vertices[i].pos[2]; }
    }

    //NSLog(@"min x:%f, max x:%f", min_x, max_x);
    //NSLog(@"min y:%f, max y:%f", min_y, max_y);
    //NSLog(@"min z:%f, max z:%f", min_z, max_z);

    self.minDimensions.v[0] = min_x;
    self.minDimensions.v[1] = min_y;
    self.minDimensions.v[2] = min_z;

    self.maxDimensions.v[0] = max_x;
    self.maxDimensions.v[1] = max_y;
    self.maxDimensions.v[2] = max_z;
}

//
// TODO: calculate center mesh for entire object as well as the subset (move this
//       method into the utils - will generate bounding box and/or origin
//       translation from an NFAssetData object
//

- (void) calcCenterPointTransform {

    GLKMatrix4 m_transform;

    GLKVector3 size = GLKVector3Subtract(self.maxDimensions, self.minDimensions);
    GLKVector3 center = GLKVector3MultiplyScalar(GLKVector3Add(self.maxDimensions, self.minDimensions), 0.5f);

    m_transform = GLKMatrix4Multiply(GLKMatrix4TranslateWithVector4(GLKMatrix4Identity, GLKVector4MakeWithVector3(center, 1.0f)),
                                     GLKMatrix4ScaleWithVector4(GLKMatrix4Identity, GLKVector4MakeWithVector3(size, 1.0f)));

    // self.modelMat = m_transform;

    self.originCenterMatrix = m_transform;
}

- (void) calcUnitScaleMatrix {

    GLKMatrix4 m_transform;

    float max_x = self.maxDimensions.v[0];
    float max_y = self.maxDimensions.v[1];
    float max_z = self.maxDimensions.v[2];

    float min_x = self.minDimensions.v[0];
    float min_y = self.minDimensions.v[1];
    float min_z = self.minDimensions.v[2];

    float abs_x, abs_y, abs_z;
    abs_x = fabsf(max_x) > fabsf(min_x) ? fabsf(max_x) : fabsf(min_x);
    abs_y = fabsf(max_y) > fabsf(min_y) ? fabsf(max_y) : fabsf(min_y);
    abs_z = fabsf(max_z) > fabsf(min_z) ? fabsf(max_z) : fabsf(min_z);

    // need to double abs_x etc. otherwise will scale -1 -> 1 instead of -0.5 -> 0.5
    abs_x *= 2.0f;
    abs_y *= 2.0f;
    abs_z *= 2.0f;

    // use the largest abs value and scale all dimensions by that value to avoid distortion
    float scaleFactor;
    scaleFactor = abs_x > abs_y ? abs_x : abs_y;
    scaleFactor = scaleFactor > abs_z ? scaleFactor : abs_z;

    GLKVector4 unitScale = {1.0f/scaleFactor, 1.0f/scaleFactor, 1.0f/scaleFactor, 1.0f};

    //
    // TODO: verify will translate center of the object to the origin
    //
    GLKVector4 origin = {0.0f, 0.0f, 0.0f, 1.0f};

    // NOTE: GLK operation with vector will concatenates matrix with vector

    m_transform = GLKMatrix4Multiply(GLKMatrix4TranslateWithVector4(GLKMatrix4Identity, origin),
                                     GLKMatrix4ScaleWithVector4(GLKMatrix4Identity, unitScale));

    //m_transform = GLKMatrix4ScaleWithVector4(GLKMatrix4Identity, unitScale);

    self.unitScalarMatrix = m_transform;
}

- (void) loadVertexData:(NFVertex_t *)pVertexData ofSize:(size_t)size {
    NSAssert(pVertexData != NULL, @"loadVertexData failed, pVertexData == NULL");
    NSAssert(size > 0, @"loadVertexData failed, size <= 0");
    memcpy(self.vertices, pVertexData, size);

    //
    // TODO: build the transform hierarchy independent of the low level (OpenGL) subset
    //       and asset data class, though will want to build the bounding box here
    //       (need to determine a way of interfacing a transform hierarchy with asset data object)
    //

    [self calcSubsetBounds];
    [self calcCenterPointTransform];
    [self calcUnitScaleMatrix];

    self.modelMat = GLKMatrix4Identity;
}

- (void) loadIndexData:(GLushort *)pIndexData ofSize:(size_t)size {
    NSAssert(pIndexData != NULL, @"loadVertexData failed, pIndexData == NULL");
    NSAssert(size > 0, @"loadVertexData failed, size <= 0");
    memcpy(self.indices, pIndexData, size);
}

//
// TODO: state should be constant (and would probably be better to pass a pointer)
//
- (void) loadResourcesWithVertexState:(NFVertState_t)state {
    //
    // NOTE: VAO should already be bound when this method is called
    //

    // create and bind new vertex buffer object associated with the VAO
    GLuint vbo;
    glGenBuffers(1, &vbo);
    self.hVBO = vbo;

    glBindBuffer(GL_ARRAY_BUFFER, self.hVBO);
    glBufferData(GL_ARRAY_BUFFER, self.numVertices * sizeof(NFVertex_t), self.vertices, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    // create and bind element buffer object associated with the VAO to store indices
    GLuint ebo;
    glGenBuffers(1, &ebo);
    self.hEBO = ebo;

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.hEBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.numIndices * sizeof(GLushort), self.indices, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    //
    // TODO: to avoid having to set the vertex attrib pointers on each draw call may want to have a VAO
    //       per subset (assuming that changing bound VAOs is cheaper than setting vertex attrib pointers)
    //

    CHECK_GL_ERROR();
}

- (void) drawWithVertexState:(NFVertState_t)state withProgram:(GLuint)hProgram withModelUniform:(GLuint)modelLoc {

    // update shader uniforms with asset specific data
    glProgramUniformMatrix4fv(hProgram, modelLoc, 1, GL_FALSE, self.modelMat.m);

    glBindBuffer(GL_ARRAY_BUFFER, self.hVBO);

    //
    // TODO: store the offset values in the NFVertState_t structure so that they are only calculated once
    //

    glVertexAttribPointer(state.vertAttrib, NFLOATS_POS, GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, pos));
    glVertexAttribPointer(state.normAttrib, NFLOATS_NORM, GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, norm));
    glVertexAttribPointer(state.texAttrib, NFLOATS_TEX, GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                          (const GLvoid *)0x00 + offsetof(NFVertex_t, texCoord));

    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.hEBO);
    glDrawElements(self.mode, (GLsizei)self.numIndices, GL_UNSIGNED_SHORT, NULL);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

@end

//
//
//

@interface NFAssetData()

@property (nonatomic, assign) GLuint hVAO;
@property (nonatomic, assign) NFVertState_t *vertexState;

//
// TODO: need to come up with a good way of correlating texture handles with
//       surface model data
//
@property (nonatomic, assign) GLuint textureId;
@property (nonatomic, assign) GLint textureUniform;

@end

@implementation NFAssetData

@synthesize subsetArray = _subsetArray;
@synthesize surfaceModelArray = _surfaceModelArray;

@synthesize hVAO = _hVAO;
@synthesize vertexState = _vertexState;

//
// TODO: need to come up with a good way of correlating texture handles with
//       surface model data
//
@synthesize textureId = _textureId;
@synthesize textureUniform = _textureUniform;

- (instancetype) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    [(NFAssetData *)self setSubsetArray:nil];

    NFVertState_t *pState = (NFVertState_t *)malloc(sizeof(NFVertState_t));
    NSAssert(pState != NULL, @"ERROR: failed to allocate vertex state in NFAssetData object");

    [self setVertexState:pState];

    return self;
}

- (void) dealloc {
    //
    // TODO: should disable all vertex attirbs when deleting the VAO just in case the OpenGL
    //       implementation doesn't properly clean them up when said VAO is deleted
    //
/*
    glDisableVertexAttribArray(m_WavefrontVAO.texAttrib);
    glDisableVertexAttribArray(m_WavefrontVAO.normAttrib);
    glDisableVertexAttribArray(m_WavefrontVAO.vertAttrib);
*/

    if (self.vertexState != NULL) {
        free(self.vertexState);
    }

    [super dealloc];
}

- (void) stepTransforms:(float)secsElapsed {

    //
    // TODO: this "animation" is currently hardcoded, need to design something simple
    //       for getting/setting a transform heirarchy and providing step/update functionality
    //

    //
    // TODO: perform rotation with quaternions if GLK implementation doesn't prevent
    //       gimbal lock with GLKMatrix4Rotate
    //

    float angle = secsElapsed * M_PI_4;

    GLKMatrix4 model = [[self.subsetArray objectAtIndex:0] modelMat];


    //
    // rotate around model Y axis
    //
/*
    bool isInvertable;
    GLKMatrix4 invertedModel = GLKMatrix4Invert(model, &isInvertable);
    if (isInvertable) {
        GLKVector4 posVec = GLKMatrix4GetColumn(invertedModel, 3);
        NSLog(@"position vector (%f, %f, %f, %f)", posVec.v[0], posVec.v[1], posVec.v[2], posVec.v[3]);

        model = GLKMatrix4Translate(model, -posVec.v[0], -posVec.v[1], -posVec.v[2]);
        model = GLKMatrix4Rotate(model, angle, 0.0f, 1.0f, 0.0f);
        model = GLKMatrix4Translate(model, posVec.v[0], posVec.v[1], posVec.v[2]);

        [[self.subsetArray objectAtIndex:0] setModelMat:model];
    }
*/

    //
    // rotate around origin
    //
    [[self.subsetArray objectAtIndex:0] setModelMat:GLKMatrix4RotateY(model, angle)];
}

- (void) drawWithProgram:(GLuint)hProgram withModelUniform:(GLuint)modelLoc {
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureId);
    glUniform1i(self.textureUniform, 0); // GL_TEXTURE0

    glBindVertexArray(self.hVAO);
    for (NFSubset *subset in self.subsetArray) {
        NFVertState_t *pState = self.vertexState;
        [subset drawWithVertexState:*pState withProgram:hProgram withModelUniform:modelLoc];
    }
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    CHECK_GL_ERROR();
}


//
// TODO: rename (and possibly) refactor this method, it will have to be called everytime the program
//       changes for drawing the asset
//
- (void) createVertexStateWithProgram:(GLuint)hProgram {
    // get shader attirbutes

    NFVertState_t *pState = self.vertexState;

    pState->vertAttrib = glGetAttribLocation(hProgram, "v_vertex\0");
    NSAssert(pState->vertAttrib != -1, @"Failed to bind attribute");

    pState->normAttrib = glGetAttribLocation(hProgram, "v_normal\0");
    NSAssert(pState->normAttrib != -1, @"Failed to bind attribute");

    pState->texAttrib = glGetAttribLocation(hProgram, "v_texcoord\0");
    NSAssert(pState->texAttrib != -1, @"Failed to bind attribute");


    // get texture unifrom location
    self.textureUniform = glGetUniformLocation(hProgram, (const GLchar *)"texSampler\0");
    NSAssert(self.textureUniform != -1, @"Failed to get texture uniform location");

    // create VAO
    GLuint vao;
    glGenVertexArrays(1, &(vao));
    self.hVAO = vao;

    glBindVertexArray(self.hVAO);

    // NOTE: the vert attributes bound to the VAO (and associated with the active VBO)
    glEnableVertexAttribArray(pState->vertAttrib);
    glEnableVertexAttribArray(pState->normAttrib);
    glEnableVertexAttribArray(pState->texAttrib);

    glBindVertexArray(0);

    CHECK_GL_ERROR();
}

- (void) loadResourcesGL {
    glBindVertexArray(self.hVAO);

    // load subset OpenGL buffers
    for (NFSubset *subset in self.subsetArray) {
        NFVertState_t *pState = self.vertexState;
        [subset loadResourcesWithVertexState:*pState];

        //
        // TODO: use load surface model method once it has been written
        //
        NFSurfaceModel *surface = [subset surfaceModel];
        NFDataMap *diffuseMap = [surface map_Kd];

        GLuint texId;
        glGenTextures(1, &texId);
        self.textureId = texId;

        //
        // TODO: use glTextureStorage2D specify texture storage requirements
        //       since for most cases they should be known
        //

        glBindTexture(GL_TEXTURE_2D, self.textureId);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

        glTexImage2D(GL_TEXTURE_2D, 0, [diffuseMap format], [diffuseMap width], [diffuseMap height], 0,
                     [diffuseMap format], [diffuseMap type], [diffuseMap data]);
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    // unbind the VAO and check for errors
    glBindVertexArray(0);
    CHECK_GL_ERROR();
}

@end
