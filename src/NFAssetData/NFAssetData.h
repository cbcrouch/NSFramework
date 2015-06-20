//
//  NSAssetData.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFCommonTypes.h"
#import "NFAssetSubset.h"

#import "NFRProgram.h"
#import "NFSurfaceModel.h"



//
// TODO: make sure struct definition will encompass a point light, spotlight, and directional light
//       and setup to operate similar to legacy OpenGL lights until working out a better model/design
//

// the following struct should contain all the light params as an OpenGL 2.1 light
/*
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
*/



@interface NFAssetData : NSObject

@property (nonatomic, assign) GLKMatrix4 modelMatrix;

@property (nonatomic, retain) NSArray* subsetArray;
@property (nonatomic, retain) NSArray* surfaceModelArray;


@property (nonatomic, retain) NFRGeometry* geometry;


- (instancetype) init;
- (void) dealloc;

- (void) stepTransforms:(float)secsElapsed;


//
// TODO: remove these terrible debug/test calls
//
- (void) applyUnitScalarMatrix;
- (void) applyOriginCenterMatrix;


- (void) generateRenderablesForProgram:(id<NFRProgram>)programObj;

//
// TODO: break apart generateRenderablesForProgram into the following three methods
//
//- (void) generateRenderables;
//- (void) bindToProgram:(id<NFRProgram>)programObj;
//- (void) assignSubroutine:(NSString*)subroutineName;

@end
