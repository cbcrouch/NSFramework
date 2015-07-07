//
//  NFLightSource.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFRResources.h"


//
// NOTE: light source protocol is so any light can be placed and accessed in a generic container
//
@protocol NFLightSource <NSObject>
@property (nonatomic, assign) GLKVector3 ambient;
@property (nonatomic, assign) GLKVector3 diffuse;
@property (nonatomic, assign) GLKVector3 specular;

@property (nonatomic, assign) GLKVector3 position;

//@property (nonatomic, readonly, retain) NFAssetData* geometry;

//
// TODO: drop need for top level NFAssetData import, will still use internally but no
//       need to expose externally (may also help avoid breaking build when including
//       NFLightSource in NFRProgram for use in the render request)
//

@property (nonatomic, readonly, retain) NFRGeometry* geometry;


@end

//
// NFPointLight
//

@interface NFPointLight : NSObject <NFLightSource>

@property (nonatomic, assign) GLKVector3 ambient;
@property (nonatomic, assign) GLKVector3 diffuse;
@property (nonatomic, assign) GLKVector3 specular;
@property (nonatomic, assign) GLKVector3 position;

//@property (nonatomic, readonly, retain) NFAssetData* geometry;

@property (nonatomic, readonly, retain) NFRGeometry* geometry;

//
// Range Constant Linear Quadratic values provided by Ogre3d
// (100% intensity at 0 distance, most light falls in first 20% of range)
//
/*
    Range  Constant  Linear   Quadratic
    3250,  1.0,      0.0014,  0.000007
    600,   1.0,      0.007,   0.0002
    325,   1.0,      0.014,   0.0007
    200,   1.0,      0.022,   0.0019
    160,   1.0,      0.027,   0.0028
    100,   1.0,      0.045,   0.0075
    65,    1.0,      0.07,    0.017
    50,    1.0,      0.09,    0.032
    32,    1.0,      0.14,    0.07
    20,    1.0,      0.22,    0.20
    13,    1.0,      0.35,    0.44
    7,     1.0,      0.7,     1.8
*/

@property (nonatomic, assign) float constantAttenuation;
@property (nonatomic, assign) float linearAttenuation;
@property (nonatomic, assign) float quadraticAttenuation;

@end

//
// NFDirectionalLight
//

@interface NFDirectionalLight : NSObject <NFLightSource>

@property (nonatomic, assign) GLKVector3 ambient;
@property (nonatomic, assign) GLKVector3 diffuse;
@property (nonatomic, assign) GLKVector3 specular;

//
// NOTE: directional light will use a position to place some debug geometry
//       in the scene to so there some visual feedback to its presence
//
@property (nonatomic, assign) GLKVector3 position;

//@property (nonatomic, readonly, retain) NFAssetData* geometry;

@property (nonatomic, readonly, retain) NFRGeometry* geometry;

@property (nonatomic, assign) GLKVector3 direction;

@end

//
// NFSpotLight
//

@interface NFSpotLight : NSObject <NFLightSource>

@property (nonatomic, assign) GLKVector3 ambient;
@property (nonatomic, assign) GLKVector3 diffuse;
@property (nonatomic, assign) GLKVector3 specular;
@property (nonatomic, assign) GLKVector3 position;

//@property (nonatomic, readonly, retain) NFAssetData* geometry;

@property (nonatomic, readonly, retain) NFRGeometry* geometry;

@property (nonatomic, assign) GLKVector3 direction;

@property (nonatomic, assign) float innerCutOff;
@property (nonatomic, assign) float outerCutOff;

@property (nonatomic, assign) float constantAttenuation;
@property (nonatomic, assign) float linearAttenuation;
@property (nonatomic, assign) float quadraticAttenuation;

@end
