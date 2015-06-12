//
//  NSAssetData.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFCommonTypes.h"
#import "NFSurfaceModel.h"

#import "NFRProgram.h"


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

//
// TODO: best way to draw wireframe polygons is to use glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
//       then use glPolygoMode(GL_FRONT_AND_BACK, GL_FILL) to set back to normal
//



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


- (void) bindSubsetToProgramObj:(id<NFRProgram>)programObj withVAO:(GLuint)hVAO;

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


//
// TODO: the NFAssetData and NFSubset bind functions really need a better name
//
- (void) bindAssetToProgramObj:(id<NFRProgram>)programObj;
- (void) drawWithProgramObject:(id<NFRProgram>)programObj withSubroutine:(NSString*)subroutine;

@end
