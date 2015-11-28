//
//  NFRRenderRequest.h
//  NSFramework
//
//  Copyright © 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFRProgramProtocol.h"

#import "NFLightSource.h"
#import "NFRResources.h"
#import "NFRRenderTarget.h"



@protocol NFRCommandBufferProtcol <NSObject>

// array of blocks to process

@optional

// addLight
// addGeometry

@end


// NFRCommandBufferProtocol

// NFRCommandBuffer



@interface NFRRenderRequest : NSObject

@property (nonatomic, retain) id<NFRProgram> program;
@property (nonatomic, retain) NSMutableArray* geometryArray;
@property (nonatomic, retain) NSMutableArray* lightsArray;

@property (nonatomic, retain) NFRRenderTarget* renderTarget;

- (void) addGeometry:(NFRGeometry*)geometry;
- (void) addLight:(id<NFLightSource>)light;

- (void) process;

@end
