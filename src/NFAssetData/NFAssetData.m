//
//  NSAssetData.m
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#import "NFAssetData.h"
#import "NFRProgramProtocol.h"


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

    // update geometry object model matrix
    for (int i=0; i<[self.subsetArray count]; ++i) {
        NFAssetSubset* subset = (self.subsetArray)[0];
        [subset setSubsetModelMat:transformBlock(subset.subsetModelMat, secsElapsed)];
        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.modelMatrix, subset.subsetModelMat);

        NFRGeometry* geo = (self.geometryArray)[i];
        geo.modelMatrix = renderModelMat;
    }
}

- (void) applyUnitScalarMatrix {
    for (NFAssetSubset* subset in self.subsetArray) {
        GLKMatrix4 model = [subset unitScalarMatrix];
        [subset setSubsetModelMat:model];
    }
}

- (void) applyOriginCenterMatrix {
    for (NFAssetSubset* subset in self.subsetArray) {
        GLKMatrix4 model = [subset originCenterMatrix];
        [subset setSubsetModelMat:model];
    }
}

- (void) generateRenderables {
    NSMutableArray* geoArray = [[NSMutableArray alloc] initWithCapacity:[self.subsetArray count]];

    for (NFAssetSubset *subset in self.subsetArray) {
        NFRGeometry* geometry = [[NFRGeometry alloc] init];

        NF_VERTEX_FORMAT vertexFormat = subset.vertexFormat;
        NFRBufferAttributes* bufferAttribs = [[NFRBufferAttributes alloc] initWithFormat:vertexFormat];

        geometry.vertexBuffer = [[NFRBuffer alloc] initWithType:kBufferTypeVertex usingAttributes:bufferAttribs];
        geometry.indexBuffer = [[NFRBuffer alloc] initWithType:kBufferTypeIndex usingAttributes:bufferAttribs];

        NFSurfaceModel *surface = subset.surfaceModel;
        if (surface) {
            geometry.surfaceModel = surface;
            [geometry syncSurfaceModel];
        }

        geometry.mode = subset.mode;

        GLKMatrix4 renderModelMat = GLKMatrix4Multiply(self.modelMatrix, subset.subsetModelMat);
        geometry.modelMatrix = renderModelMat;

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
        [geometry.vertexBuffer loadData:subset.vertices ofType:vertexBufferType numberOfElements:subset.numVertices];
        [geometry.indexBuffer loadData:subset.indices ofType:kBufferDataTypeUShort numberOfElements:subset.numIndices];

        [geoArray addObject:geometry];
    }

    self.geometryArray = geoArray;
}

@end
