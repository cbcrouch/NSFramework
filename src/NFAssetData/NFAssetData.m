//
//  NSAssetData.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"


@implementation NFAssetData

- (instancetype) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _subsetArray = nil;
    _modelMatrix = GLKMatrix4Identity;
    return self;
}

- (void) dealloc {

    //
    // TODO: need proper cleanup of NFR objects
    //

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
    GLKMatrix4 model = [[self.subsetArray objectAtIndex:0] subsetModelMat];
    [[self.subsetArray objectAtIndex:0] setSubsetModelMat:GLKMatrix4RotateY(model, angle)];


    //
    // update geometry object model matrix
    //
    for (NFAssetSubset *subset in self.subsetArray) {
        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.modelMatrix, subset.subsetModelMat);
        [self.geometry setModelMatrix:renderModelMat];
    }
}

- (void) applyUnitScalarMatrix {
    GLKMatrix4 model = [[self.subsetArray objectAtIndex:0] unitScalarMatrix];
    //[[self.subsetArray objectAtIndex:0] setUnitScalarMatrix:[[self.subsetArray objectAtIndex:0] modelMatrix]];
    [[self.subsetArray objectAtIndex:0] setSubsetModelMat:model];
}

- (void) applyOriginCenterMatrix {
    GLKMatrix4 model = [[self.subsetArray objectAtIndex:0] originCenterMatrix];
    //[[self.subsetArray objectAtIndex:0] setOriginCenterMatrix:[[self.subsetArray objectAtIndex:0] modelMatrix]];
    [[self.subsetArray objectAtIndex:0] setSubsetModelMat:model];
}

- (void) generateRenderablesForProgram:(id<NFRProgram>)programObj {

    //
    // TODO: need to setup proper ownership and refence release for NFR objects
    //
    NFRBufferAttributes* bufferAttribs = [[[NFRBufferAttributes alloc] initWithFormat:kVertexFormatDefault] retain];

    NFRBuffer* vertexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeVertex usingAttributes:bufferAttribs] retain];
    NFRBuffer* indexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeIndex usingAttributes:bufferAttribs] retain];

    NSAssert([self.subsetArray count] == 1, @"ERROR: NFRGeometry object currently only supports one asset subset");
    NFRGeometry* geometry = [[[NFRGeometry alloc] init] retain];

    //
    // TODO: these set calls should increment the reference count if not using ARC so that the objects can be
    //       declared autorelease when created (geometry dealloc will have to release them)
    //
    [geometry setVertexBuffer:vertexBuffer];
    [geometry setIndexBuffer:indexBuffer];

    for (NFAssetSubset *subset in self.subsetArray) {
        NFSurfaceModel *surface = [subset surfaceModel];
        if (surface) {
            [geometry setSurfaceModel:surface];
        }

        [geometry setMode:subset.mode];

        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.modelMatrix, subset.subsetModelMat);
        [geometry setModelMatrix:renderModelMat];

        [vertexBuffer loadData:subset.vertices ofType:kBufferDataTypeNFVertex_t numberOfElements:subset.numVertices];
        [indexBuffer loadData:subset.indices ofType:kBufferDataTypeUShort numberOfElements:subset.numIndices];
    }
    [geometry syncSurfaceModel];



    // handle in bindToProgram method
    [programObj configureVertexInput:bufferAttribs];
    [programObj configureVertexBufferLayout:vertexBuffer withAttributes:bufferAttribs];

    //vertexBuffer.bufferAttributes


    // handle in assignSubroutine
    [geometry setSubroutineName:@"PhongSubroutine"];


    //
    // TODO: will either want a geometry subset or geometry hierarchy structure object to apply transform hierarchies to
    //
    [self setGeometry:geometry];
}

@end
