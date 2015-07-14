//
//  NFAssetLoader.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFCommonTypes.h"
#import "NFAssetData.h"


typedef NS_ENUM(NSUInteger, ASSET_TYPE) {
    kWavefrontObj,
    kSolidPlane,
    kGridWireframe,
    kAxisWireframe,

    kSolidCylinder,
    kSolidUVSphere,
    kSolidCone

    //
    // TODO: add support for solid cones and cylinders
    //
};

@interface NFAssetLoader : NSObject

+ (NFAssetData *) allocAssetDataOfType:(ASSET_TYPE)type withArgs:(id)firstArg, ... NS_REQUIRES_NIL_TERMINATION;

@end
