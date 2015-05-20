//
//  NFGTResources.h
//  NSFramework
//
//  Created by cbcrouch on 5/12/15.
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFGTDataTypes.h"

@protocol GTDevice;


@protocol GTResource <NSObject>
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


@protocol GTTexture <GTResource>
typedef NS_ENUM(NSUInteger, GTTextureType) {
    GTTextureType1D = 0,
    GTTextureType1DArray = 1,
    GTTextureType2D = 2,
    GTTextureType2DArray = 3,
    GTTextureType2DMultisample = 4,
    GTTextureTypeCube = 5,
    GTTextureType3D = 7
};

@property (nonatomic, readonly) GTTextureType textureType;
@property (nonatomic, readonly) GTPixelFormat pixelFormat;
@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;
@property (nonatomic, readonly) NSUInteger depth;
@property (nonatomic, readonly) NSUInteger mipmapLevelCount;
@property (nonatomic, readonly) NSUInteger arrayLength;
@property (nonatomic, readonly) NSUInteger sampleCount;

@property (readonly, getter=isFramebufferOnly) BOOL framebufferOnly;
@property (readonly) id< GTResource > rootResource;

- (void) replaceRegion:(GTRegion)region
           mipmapLevel:(NSUInteger)level
                 slice:(NSUInteger)slice
             withBytes:(const void *)pixelBytes
           bytesPerRow:(NSUInteger)bytesPerRow
         bytesPerImage:(NSUInteger)bytesPerImage;

- (void) replaceRegion:(GTRegion)region
           mipmapLevel:(NSUInteger)level
             withBytes:(const void *)pixelBytes
           bytesPerRow:(NSUInteger)bytesPerRow;

- (void) getBytes:(void *)pixelBytes
      bytesPerRow:(NSUInteger)bytesPerRow
    bytesPerImage:(NSUInteger)bytesPerImage
       fromRegion:(GTRegion)region
      mipmapLevel:(NSUInteger)mipmapLevel
            slice:(NSUInteger)slice;

- (void) getBytes:(void *)pixelBytes
      bytesPerRow:(NSUInteger)bytesPerRow
       fromRegion:(GTRegion)region
      mipmapLevel:(NSUInteger)mipmapLevel;

- (id<GTTexture>) newTextureViewWithPixelFormat:(GTPixelFormat)pixelFormat;
@end



@interface GTTextureDescriptor <NSObject, NSCopying>
@property (nonatomic, assign) GTTextureType textureType;
@property (nonatomic, assign) GTPixelFormat pixelFormat;
@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;
@property (nonatomic, assign) NSUInteger depth;
@property (nonatomic, assign) NSUInteger mipmapLevelCount;
@property (nonatomic, assign) NSUInteger arrayLength;
@property (nonatomic, assign) NSUInteger sampleCount;
@property (nonatomic, assign) GTResourceOptions resourceOptions;

+ (GTTextureDescriptor *) texture2DDescriptorWithPixelFormat:(GTPixelFormat)pixelFormat
                                                       width:(NSUInteger)width
                                                      height:(NSUInteger)height
                                                   mipmapped:(BOOL)mipmapped;

+ (GTTextureDescriptor *) textureCubeDescriptorWithPixelFormat:(GTPixelFormat)pixelFormat
                                                          size:(NSUInteger)size
                                                     mipmapped:(BOOL)mipmapped;
@end


@protocol GTSamplerState <NSObject>
@property (nonatomic, readonly) id<GTDevice> device;
@property (nonatomic, readonly) NSString* label;
@end



@protocol GTSamplerDescriptor <NSObject, NSCopying>

//
// TODO: implement
//

@end



@protocol GTBuffer <GTResource>
// the logical size of the buffer (in bytes), allocated size may be larger due to alignment requirements
@property (nonatomic, readonly) NSUInteger length;

- (id<GTTexture>) newTextureWithDescriptor:(GTTextureDescriptor *)descriptor offset:(NSUInteger)offset
                               bytesPerRow:(NSUInteger)bytesPerRow;
- (void *) contents;
@end





@interface NFGTResources : NSObject

@end
