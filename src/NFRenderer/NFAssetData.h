//
//  NSAssetData.h
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFSurfaceModel.h"


//
// TODO: move vertex/face definitions into NFRCommonTypes.h or something similar so that other
//       modules don't have to include the NFAssetData
//

#define NFLOATS_POS 4
#define NFLOATS_NORM 4
#define NFLOATS_TEX 3

typedef struct NFVertex_t {
    // NOTE: w component of norm should be 0.0, and 1.0 for position (according to GLSL documentation
    //       for vectors w = 0 and for points w = 1)
    GLfloat pos[4];
    GLfloat norm[4];
    GLfloat texCoord[3];
} NFVertex_t;

typedef struct NFFace_t {
    GLushort indices[3];

    //
    // TODO: in order to perform @encode on a struct it appears that all its members must be
    //       primitive data types, verify that this is correct and not a bug
    //
    //GLKVector4 normal;
    GLfloat normal[4];

    GLfloat area;
} NFFace_t;



//
// TODO: make sure struct definition will encompass a point light, spotlight, and directional light
//       and setup to operate similar to legacy OpenGL lights until working out a better model/design
//

// the following struct should contain all the light params as an OpenGL 2.1 light

typedef struct NFLight_t {
    float pos[4];
    float diffuseColor[4];
    float specularColor[4];

    float constantAttenuation;
    float linearAttenuation;
    float quadraticAttenuation;

    float spotCutoff;
    float spotExponent;
    float spotDirection[3];
} NFLight_t;


typedef NS_ENUM(NSUInteger, DRAWING_MODE) {
    kDrawLineStrip,
    kDrawLineLoop,
    kDrawLines,
    kDrawTriangleStrip,
    kDrawTriangleFan,
    kDrawTriangles
};



@interface NFSubset : NSObject

@property (nonatomic, assign) DRAWING_MODE drawMode;

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

@end


@interface NFAssetData : NSObject

@property (nonatomic, assign) GLKMatrix4 modelMatrix;

@property (nonatomic, retain) NSArray *subsetArray;
@property (nonatomic, retain) NSArray *surfaceModelArray;

- (instancetype) init;
- (void) dealloc;

- (void) stepTransforms:(float)secsElapsed;


//
// TODO: remove these terrible debug/test calls
//
- (void) applyUnitScalarMatrix;
- (void) applyOriginCenterMatrix;


- (void) drawWithProgram:(GLuint)hProgram withModelUniform:(GLuint)modelLoc;

- (void) createVertexStateWithProgram:(GLuint)hProgram;
- (void) loadResourcesGL;

@end
