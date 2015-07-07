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

#import "NFSurfaceModel.h"


@interface NFAssetData : NSObject

@property (nonatomic, assign) GLKMatrix4 modelMatrix;

@property (nonatomic, retain) NSArray* subsetArray;
@property (nonatomic, retain) NSArray* surfaceModelArray;

@property (nonatomic, retain) NFRGeometry* geometry;


- (instancetype) init;
- (void) dealloc;

- (void) stepTransforms:(float)secsElapsed;

- (void) generateRenderables;


//
// TODO: remove these terrible debug/test calls
//
- (void) applyUnitScalarMatrix;
- (void) applyOriginCenterMatrix;

- (void) assignSubroutine:(NSString*)subroutineName;

@end
