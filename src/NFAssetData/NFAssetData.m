//
//  NSAssetData.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"
#import "NFRProgramProtocol.h"


@implementation NFAssetData

- (NFRGeometry*) geometry {
    if (_geometry == nil) {
        _geometry = [[[NFRGeometry alloc] init] autorelease];
    }
    return _geometry;
}

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

- (void) generateRenderables {
    //
    // TODO: will either want a geometry subset or geometry hierarchy structure object to apply transform hierarchies to
    //
    NSAssert([self.subsetArray count] == 1, @"ERROR: NFRGeometry object currently only supports one asset subset");

    //
    // TODO: need a much cleaner way of handling the NFRBufferAttributes vertex format
    //
    NFR_VERTEX_FORMAT vertexFormat;
    NFAssetSubset* testSubset = [self.subsetArray objectAtIndex:0];
    if (testSubset.vertexType == kNFVertexType) {
        vertexFormat = kVertexFormatDefault;
    }
    else {
        vertexFormat = kVertexFormatDebug;
    }
    NFRBufferAttributes* bufferAttribs = [[[NFRBufferAttributes alloc] initWithFormat:vertexFormat] autorelease];

    NFRBuffer* vertexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeVertex usingAttributes:bufferAttribs] autorelease];
    NFRBuffer* indexBuffer = [[[NFRBuffer alloc] initWithType:kBufferTypeIndex usingAttributes:bufferAttribs] autorelease];

    [self.geometry setVertexBuffer:vertexBuffer];
    [self.geometry setIndexBuffer:indexBuffer];

    for (NFAssetSubset *subset in self.subsetArray) {
        NFSurfaceModel *surface = [subset surfaceModel];
        if (surface) {
            [self.geometry setSurfaceModel:surface];
            [self.geometry syncSurfaceModel];
        }

        [self.geometry setMode:subset.mode];

        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.modelMatrix, subset.subsetModelMat);
        [self.geometry setModelMatrix:renderModelMat];

        NFR_BUFFER_DATA_TYPE vertexBufferType = kBufferDataTypeUnknown;
        switch (subset.vertexType) {
            case kNFVertexType:
                vertexBufferType = kBufferDataTypeNFVertex_t;
                break;

            case kNFDebugVertexType:
                vertexBufferType = kBufferDataTypeNFDebugVertex_t;
                break;
                
            default:
                break;
        }

        NSAssert(vertexBufferType != kBufferDataTypeUnknown, @"ERROR: NFAssetData can not recongize subset vertex type");
        [vertexBuffer loadData:subset.vertices ofType:vertexBufferType numberOfElements:subset.numVertices];
        [indexBuffer loadData:subset.indices ofType:kBufferDataTypeUShort numberOfElements:subset.numIndices];
    }
}

//
// TODO: remove this call after subroutines have been removed from the shader
//
- (void) assignSubroutine:(NSString*)subroutineName {
    [self.geometry setSubroutineName:subroutineName];
}

@end
