//
//  NFAssetSubset.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFCommonTypes.h"
#import "NFSurfaceModel.h"


typedef NS_ENUM(NSUInteger, DRAWING_MODE) {
    kDrawLineStrip,
    kDrawLineLoop,
    kDrawLines,
    kDrawTriangleStrip,
    kDrawTriangleFan,
    kDrawTriangles
};

//
// TODO: best way to draw wireframe polygons is to use glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
//       then use glPolygoMode(GL_FRONT_AND_BACK, GL_FILL) to set back to normal
//

@interface NFAssetSubset : NSObject

@property (nonatomic, assign) void* vertices;
@property (nonatomic, assign) NSUInteger numVertices;
@property (nonatomic, assign) NF_VERTEX_FORMAT vertexFormat;

@property (nonatomic, assign) GLushort* indices;
@property (nonatomic, assign) NSUInteger numIndices;

@property (nonatomic, assign) DRAWING_MODE drawMode;

@property (nonatomic, assign) GLenum mode;
@property (nonatomic, assign) GLKMatrix4 subsetModelMat;

@property (nonatomic, assign) GLKMatrix4 unitScalarMatrix;
@property (nonatomic, assign) GLKMatrix4 originCenterMatrix;

// surface model is weak since memory will be retained the asset data's surface model array property
@property (nonatomic, weak) NFSurfaceModel* surfaceModel;

- (void) allocateIndicesWithNumElts:(NSUInteger)num;
- (void) loadIndexData:(GLushort *)pIndexData ofSize:(size_t)size;

- (void) allocateVerticesOfType:(NF_VERTEX_FORMAT)vertexFormat withNumVertices:(NSUInteger)numVertices;
- (void) loadVertexData:(void*)pData ofType:(NF_VERTEX_FORMAT)vertexFormat withNumVertices:(NSUInteger)numVertices;

@end
