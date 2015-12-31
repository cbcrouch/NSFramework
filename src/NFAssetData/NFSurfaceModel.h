//
//  NFSurfaceModel.h
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFRDataMap.h"


//
// TODO: NFSurfaceModel should be a protocol so that NFPhongModel, and NFPBRModel classes
//       could both be used in the same way when rendering an NFAssetData object
//
@interface NFSurfaceModel : NSObject


typedef NS_ENUM(NSUInteger, DEFAULT_SURFACE) {
    kTestGrid,
    kTestGridColored,
    kGray127
};

//
// TODO: take a DEFAULT_SURFACE argument and generate accordingly
//
+ (NFSurfaceModel *) defaultSurfaceModel;



@property (nonatomic, strong) NSString *name;


//
// TODO: need a validity check that will verify that all values are present for the given illumination model
//

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

@property (nonatomic, strong) NFRDataMap *map_Ka; // ambient color texture map (will be same as diffuse most of the time)
@property (nonatomic, strong) NFRDataMap *map_Kd; // diffuse color texture map
@property (nonatomic, strong) NFRDataMap *map_Ks; // specular color texture map
@property (nonatomic, strong) NFRDataMap *map_Ns; // specular highlight component

@property (nonatomic, strong) NFRDataMap *map_Tr; // transparency map

@property (nonatomic, strong) NFRDataMap *map_bump;   // bump map
@property (nonatomic, strong) NFRDataMap *map_disp;   // displacement map
@property (nonatomic, strong) NFRDataMap *map_decalT; // decal texture

@end
