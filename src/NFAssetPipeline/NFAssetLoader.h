//
//  NFAssetLoader.h
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFAssetData.h"


typedef NS_ENUM(NSUInteger, ASSET_TYPE) {
    kWavefrontObj,
    kSolidPlane,
    kGridWireframe,
    kAxisWireframe
};

@interface NFAssetLoader : NSObject

+ (NFAssetData *) allocAssetDataOfType:(ASSET_TYPE)type withArgs:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

@end
