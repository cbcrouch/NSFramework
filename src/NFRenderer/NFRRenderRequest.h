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


// render request will take general render state like setting clear calls or depth buffer state etc.

// command buffer and program object will each have a descriptor object (will contain vertex format, uniforms, etc.)
// and when in debug mode a render request will verify that they both match

@protocol NFRCommandBufferProtocol <NSObject>

- (void) drawWithProgram:(id<NFRProgram>)program;

@end


//
// TODO: is there a better way to encode commands for a specific format/program
//       than using specific classes ?? (check Metal API command buffer examples)
//

@interface NFRCommandBufferDebug : NSObject <NFRCommandBufferProtocol>

@property (nonatomic, retain) NSMutableArray< NFRGeometry* >* geometryArray;

- (void) addGeometry:(NFRGeometry*)geometry;

- (void) drawWithProgram:(id<NFRProgram>)program;

@end


@interface NFRCommandBufferDefault : NSObject <NFRCommandBufferProtocol>

@property (nonatomic, retain) NSMutableArray< NFRGeometry* >* geometryArray;
@property (nonatomic, retain) NSMutableArray< id<NFLightSource> >* lightsArray;

- (void) addGeometry:(NFRGeometry*)geometry;
- (void) addLight:(id<NFLightSource>)light;

- (void) drawWithProgram:(id<NFRProgram>)program;

@end


@interface NFRRenderRequest : NSObject

@property (nonatomic, retain) id<NFRProgram> program;

//
// TODO: apply generics to all container usage
//
@property (nonatomic, retain) NSMutableArray< id<NFRCommandBufferProtocol> >* commandBufferArray;

- (void) addCommandBuffer:(id<NFRCommandBufferProtocol>)commandBuffer;
- (void) process;

@end
