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

#import "NFRProgram.h"

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

@property (nonatomic, assign) DRAWING_MODE drawMode;

@property (nonatomic, assign) GLenum mode;
@property (nonatomic, assign) GLKMatrix4 subsetModelMat;

@property (nonatomic, assign) GLKMatrix4 unitScalarMatrix;
@property (nonatomic, assign) GLKMatrix4 originCenterMatrix;


// assign is similar to weak, weak releases and sets the object to nil after
// no more objects are pointing to it while assign will not
@property (nonatomic, assign) NFSurfaceModel* surfaceModel;

- (void) allocateVerticesWithNumElts:(NSUInteger)num;
- (void) allocateIndicesWithNumElts:(NSUInteger)num;

- (void) loadVertexData:(NFVertex_t *)pVertexData ofSize:(size_t)size;
- (void) loadIndexData:(GLushort *)pIndexData ofSize:(size_t)size;

- (void) bindSubsetToProgramObj:(id<NFRProgram>)programObj withVAO:(GLuint)hVAO;

- (void) drawWithProgram:(id<NFRProgram>)programObj withAssetModelMatrix:(GLKMatrix4)assetModelMatrix;

@end
