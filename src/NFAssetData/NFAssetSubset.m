//
//  NFAssetSubset.m
//  NSFramework
//
//  Created by cbcrouch on 6/12/15.
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetSubset.h"

#import <GLKit/GLKit.h>


@interface NFAssetSubset()

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


//
// TODO: remove all OpenGL primitives
//
@property (nonatomic, assign) GLuint hVBO;
@property (nonatomic, assign) GLuint hEBO;


//
// TODO: rename something like calcUnitLengthTransform and add a calcBoundingBox method
//
- (void) calcCenterPointTransform;

@end

@implementation NFAssetSubset

- (instancetype) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _drawMode = kDrawTriangles;
    _subsetModelMat = GLKMatrix4Identity;

    _vertices = NULL;
    _indices = NULL;
    _numVertices = 0;
    _numIndices = 0;

    _mode = GL_TRIANGLES;
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
            NSAssert(NO, @"ERROR: setDrawMode received unknown type");
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

    //GLKVector3 size = GLKVector3Subtract(self.maxDimensions, self.minDimensions);
    GLKVector3 center = GLKVector3MultiplyScalar(GLKVector3Add(self.maxDimensions, self.minDimensions), 0.5f);

    GLKMatrix4 translateMat = GLKMatrix4TranslateWithVector4(GLKMatrix4Identity, GLKVector4MakeWithVector3(center, 1.0f));

    //GLKMatrix4 scaleMat = GLKMatrix4ScaleWithVector4(GLKMatrix4Identity, GLKVector4MakeWithVector3(size, 1.0f));

    //
    // TODO: this should only translate geometry center point to the origin without any scaling
    //

    //self.originCenterMatrix = GLKMatrix4Multiply(translateMat, scaleMat);

    self.originCenterMatrix = translateMat;
}

- (void) calcUnitScaleMatrix {
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

    GLKVector4 origin = {0.0f, 0.0f, 0.0f, 1.0f};

    //
    // TODO: remove origin translation from the calculations to determine the unit scalar matrix
    //

    self.unitScalarMatrix = GLKMatrix4Multiply(GLKMatrix4TranslateWithVector4(GLKMatrix4Identity, origin),
                                               GLKMatrix4ScaleWithVector4(GLKMatrix4Identity, unitScale));

    //self.unitScalarMatrix = GLKMatrix4ScaleWithVector4(GLKMatrix4Identity, unitScale);
}


//
// TODO: fix and cleanup the generation and add some display code for the AABB (axis aligned bounding box)
//

- (void) loadVertexData:(NFVertex_t *)pVertexData ofSize:(size_t)size {
    NSAssert(pVertexData != NULL, @"loadVertexData failed, pVertexData == NULL");
    NSAssert(size > 0, @"loadVertexData failed, size <= 0");
    memcpy(self.vertices, pVertexData, size);

    //
    // TODO: build the transform hierarchy independent of the low level (OpenGL) subset
    //       and asset data class, though will want to build the bounding box here
    //       (need to determine a way of interfacing a transform hierarchy with asset data object)
    //


    GLfloat min_x, max_x;
    GLfloat min_y, max_y;
    GLfloat min_z, max_z;
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

    //
    // TODO: probably a very good idea to keep the max/min x,y,z in the subset to provide
    //       an easy way to cull anything not in the view volume
    //

    //NSLog(@"min x:%f, max x:%f", min_x, max_x);
    //NSLog(@"min y:%f, max y:%f", min_y, max_y);
    //NSLog(@"min z:%f, max z:%f", min_z, max_z);

    // NOTE: this transform will scale and center a unit cube so that it fits
    //       around the surrounding object
    GLKMatrix4 m_transform;

#if 1

    GLfloat abs_x, abs_y, abs_z;
    abs_x = fabsf(max_x) > fabsf(min_x) ? fabsf(max_x) : fabsf(min_x);
    abs_y = fabsf(max_y) > fabsf(min_y) ? fabsf(max_y) : fabsf(min_y);
    abs_z = fabsf(max_z) > fabsf(min_z) ? fabsf(max_z) : fabsf(min_z);

    // need to double abs_x etc. otherwise will scale -1 -> 1 instead of -0.5 -> 0.5
    abs_x *= 2.0f;
    abs_y *= 2.0f;
    abs_z *= 2.0f;

    // use the largest abs value and scale all dimensions by that value to avoid distortion
    GLfloat scaleFactor;
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

#else

    GLKVector4 sizeVec = {max_x-min_x, max_y-min_y, max_z-min_z, 1.0f};

    GLKVector4 center = {(max_x+min_x)/2.0f, (max_y+min_y)/2.0f, (max_z+min_z)/2.0f, 1.0f};

    //center = GLKVector4MultiplyScalar(center, -1.0f);

    m_transform = GLKMatrix4Multiply(GLKMatrix4TranslateWithVector4(GLKMatrix4Identity, center),
                                     GLKMatrix4ScaleWithVector4(GLKMatrix4Identity, sizeVec));

#endif

    //self.modelMat = m_transform;

    self.unitScalarMatrix = m_transform;


    //[self calcSubsetBounds];
    //[self calcCenterPointTransform];
    //[self calcUnitScaleMatrix];

    //
    // TODO: animations should ideally transform the model matrix, i.e. a game object is told to move
    //       along a particular vector or spline over a period of time and the animation system determines
    //       the pose and model matrix for a given time slice
    //

    // also animations should have the ability to stack and blend, for example a character can be running
    // while waving to another character


    self.subsetModelMat = GLKMatrix4Identity;
}

- (void) loadIndexData:(GLushort *)pIndexData ofSize:(size_t)size {
    NSAssert(pIndexData != NULL, @"loadVertexData failed, pIndexData == NULL");
    NSAssert(size > 0, @"loadVertexData failed, size <= 0");
    memcpy(self.indices, pIndexData, size);
}

@end
