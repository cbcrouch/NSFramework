//
//  NSAssetData.m
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"
#import "NFRProgramProtocol.h"


@implementation NFAssetData

- (NFRGeometry*) geometry {
    if (_geometry == nil) {
        _geometry = [[NFRGeometry alloc] init];
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


- (void) stepTransforms:(float)secsElapsed {

    //
    // TODO: need to modify the transform block so that it can operate stricky on a matrix with time step
    //       and then return a matrix so that internal/private details of the asset data implementation don't
    //       need to be publically exposed
    //

    // each animation can be assigned a block which will be its step transform

    transformBlock_f transformBlock = ^(GLKMatrix4 modelMatrix, float secsElapsed) {
        float angle = secsElapsed * M_PI_4;
        return GLKMatrix4RotateY(modelMatrix, angle);
    };

    GLKMatrix4 model = [(self.subsetArray)[0] subsetModelMat];
    [(self.subsetArray)[0] setSubsetModelMat:transformBlock(model, secsElapsed)];

    // update geometry object model matrix
    for (NFAssetSubset *subset in self.subsetArray) {
        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.modelMatrix, subset.subsetModelMat);
        (self.geometry).modelMatrix = renderModelMat;
    }
}

- (void) applyUnitScalarMatrix {
    GLKMatrix4 model = [(self.subsetArray)[0] unitScalarMatrix];
    //[[self.subsetArray objectAtIndex:0] setUnitScalarMatrix:[[self.subsetArray objectAtIndex:0] modelMatrix]];
    [(self.subsetArray)[0] setSubsetModelMat:model];
}

- (void) applyOriginCenterMatrix {
    GLKMatrix4 model = [(self.subsetArray)[0] originCenterMatrix];
    //[[self.subsetArray objectAtIndex:0] setOriginCenterMatrix:[[self.subsetArray objectAtIndex:0] modelMatrix]];
    [(self.subsetArray)[0] setSubsetModelMat:model];
}

- (void) generateRenderables {
    //
    // TODO: will either want a geometry subset or geometry hierarchy structure object to apply transform hierarchies to
    //
    NSAssert([self.subsetArray count] == 1, @"ERROR: NFRGeometry object currently only supports one asset subset");

    //
    // TODO: need a much cleaner way of handling the NFRBufferAttributes vertex format
    //
    NF_VERTEX_FORMAT vertexFormat;
    NFAssetSubset* testSubset = (self.subsetArray)[0];
    vertexFormat = testSubset.vertexFormat;

    NFRBufferAttributes* bufferAttribs = [[NFRBufferAttributes alloc] initWithFormat:vertexFormat];

    NFRBuffer* vertexBuffer = [[NFRBuffer alloc] initWithType:kBufferTypeVertex usingAttributes:bufferAttribs];
    NFRBuffer* indexBuffer = [[NFRBuffer alloc] initWithType:kBufferTypeIndex usingAttributes:bufferAttribs];

    (self.geometry).vertexBuffer = vertexBuffer;
    (self.geometry).indexBuffer = indexBuffer;

    for (NFAssetSubset *subset in self.subsetArray) {
        NFSurfaceModel *surface = subset.surfaceModel;
        if (surface) {
            (self.geometry).surfaceModel = surface;
            [self.geometry syncSurfaceModel];
        }

        (self.geometry).mode = subset.mode;

        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.modelMatrix, subset.subsetModelMat);
        (self.geometry).modelMatrix = renderModelMat;

        NFR_BUFFER_DATA_TYPE vertexBufferType = kBufferDataTypeUnknown;
        switch (subset.vertexFormat) {
            case kVertexFormatDefault:
                vertexBufferType = kBufferDataTypeNFVertex_t;
                break;

            case kVertexFormatDebug:
                vertexBufferType = kBufferDataTypeNFDebugVertex_t;
                break;
                
            default:
                NSLog(@"WARNING: generateRenderables called with unknown vertex buffer type");
                break;
        }

        NSAssert(vertexBufferType != kBufferDataTypeUnknown, @"ERROR: NFAssetData can not recongize subset vertex type");
        [vertexBuffer loadData:subset.vertices ofType:vertexBufferType numberOfElements:subset.numVertices];
        [indexBuffer loadData:subset.indices ofType:kBufferDataTypeUShort numberOfElements:subset.numIndices];
    }
}

@end
