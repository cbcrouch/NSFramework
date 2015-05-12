//
//  NFGTResources.h
//  NSFramework
//
//  Created by cbcrouch on 5/12/15.
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GTDevice;


//
// TODO: need to implement:
//
// - GTTexture
// - GTSamplerState


@protocol GTBuffer
//
// TODO: implement
//
@end

@protocol GTResource
typedef NS_ENUM(NSUInteger, GTPurgeableState) {
    kGTPurgeableStateKeepCurrent = 1,
    kGTPurgeableStateNonVolatile = 2,
    kGTPurgeableStateVolatile = 3,
    kGTPurgeableStateEmpty = 4
};

typedef NS_ENUM(NSUInteger, GTCPUCacheMode) {
    kGTCPUCacheModeDefaultCache  = 0,
    kGTCPUCacheModeWriteCombined = 1
};

typedef NS_ENUM(NSUInteger, GTResourceOptions) {
    kGTResourceOptionCPUCacheModeDefault = kGTCPUCacheModeDefaultCache,
    kGTResourceOptionCPUCacheModeWriteCombined = kGTCPUCacheModeWriteCombined
};

@property (nonatomic, readonly) GTCPUCacheMode cpuCacheMode;

@property (nonatomic, readonly) id<GTDevice> device;
@property (nonatomic, copy) NSString *label;

- (GTPurgeableState) setPurgeableState:(GTPurgeableState)state;
@end






@interface NFGTResources : NSObject

@end
