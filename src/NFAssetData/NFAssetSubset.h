//
//  NFAssetSubset.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFCommonTypes.h"

#import "NFRProgram.h"
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
@property (nonatomic, assign) NF_VERTEX_TYPE vertexType;

@property (nonatomic, assign) GLushort* indices;
@property (nonatomic, assign) NSUInteger numIndices;

@property (nonatomic, assign) DRAWING_MODE drawMode;

@property (nonatomic, assign) GLenum mode;
@property (nonatomic, assign) GLKMatrix4 subsetModelMat;

@property (nonatomic, assign) GLKMatrix4 unitScalarMatrix;
@property (nonatomic, assign) GLKMatrix4 originCenterMatrix;


// assign is similar to weak, weak releases and sets the object to nil after
// no more objects are pointing to it while assign will not
@property (nonatomic, assign) NFSurfaceModel* surfaceModel;

- (void) allocateIndicesWithNumElts:(NSUInteger)num;
- (void) loadIndexData:(GLushort *)pIndexData ofSize:(size_t)size;

- (void) allocateVerticesOfType:(NF_VERTEX_TYPE)vertexType withNumVertices:(NSUInteger)numVertices;
- (void) loadVertexData:(void*)pData ofType:(NF_VERTEX_TYPE)vertexType withNumVertices:(NSUInteger)numVertices;

@end
