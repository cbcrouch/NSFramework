//
//  NFSurfaceModel.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFRDataMap.h"

//
// TODO: NFSurfaceModel should be a protocol so that NFWavefrontModel, NFGLModel, and NFPBRModel classes
//       could both be used in the same way when rendering an NFAssetData object
//
@interface NFSurfaceModel : NSObject


typedef NS_ENUM(NSUInteger, DEFAULT_SURFACES) {
    kTestGrid,
    kTestGridColored,
    kGray127
};

//
// TODO: take a DEFAULT_SURFACES argument and generate accordingly
//
+ (NFSurfaceModel *) defaultSurfaceModel;



@property (nonatomic, retain) NSString *name;

@property (nonatomic, assign) float Ns; // specular coefficient
@property (nonatomic, assign) float Ni; // optical density (also known as index of refraction)

//
// TODO: work out correct format of dissolve factor
//
// dissolve factor e.g. d -halo 0.0 or d 0.0
//@property (nonatomic, assign) float d;
//@property (nonatomic, assign) BOOL dHalo;

@property (nonatomic, assign) float Tr;      // transparency
@property (nonatomic, assign) GLKVector3 Tf; // transmission factor

@property (nonatomic, assign) NSInteger illum; // illumination model

@property (nonatomic, assign) GLKVector3 Ka; // ambient color
@property (nonatomic, assign) GLKVector3 Kd; // diffuse color
@property (nonatomic, assign) GLKVector3 Ks; // specular color
@property (nonatomic, assign) GLKVector3 Ke; // emissive color

@property (nonatomic, retain) NFRDataMap *map_Ka; // ambient color texture map (will be same as diffuse most of the time)
@property (nonatomic, retain) NFRDataMap *map_Kd; // diffuse color texture map
@property (nonatomic, retain) NFRDataMap *map_Ks; // specular color texture map
@property (nonatomic, retain) NFRDataMap *map_Ns; // specular highlight component

@property (nonatomic, retain) NFRDataMap *map_Tr; // transparency map

@property (nonatomic, retain) NFRDataMap *map_bump;   // bump map
@property (nonatomic, retain) NFRDataMap *map_disp;   // displacement map
@property (nonatomic, retain) NFRDataMap *map_decalT; // decal texture

@end
