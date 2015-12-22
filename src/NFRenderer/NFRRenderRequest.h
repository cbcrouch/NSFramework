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



@protocol NFRCommandBufferProtocol <NSObject>

//typedef void (^processBlock)(void);
//typedef void (^processBlock)(id<NFRProgram>);

//- (processBlock) getProcessBlock;

//@property (nonatomic, retain) NSMutableArray* commandArray;
//- (NSMutableArray*) getCommandArray;

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


@interface NFRCommandBufferDisplay : NSObject <NFRCommandBufferProtocol>

- (void) drawWithProgram:(id<NFRProgram>)program;

@end



@interface NFRRenderRequest : NSObject

@property (nonatomic, retain) id<NFRProgram> program;
@property (nonatomic, retain) NSMutableArray* geometryArray;
@property (nonatomic, retain) NSMutableArray* lightsArray;


//
// TODO: apply generics to all container usage
//
@property (nonatomic, retain) NSMutableArray< id<NFRCommandBufferProtocol> >* commandBufferArray;


@property (nonatomic, retain) NFRRenderTarget* renderTarget;

- (void) addGeometry:(NFRGeometry*)geometry;
- (void) addLight:(id<NFLightSource>)light;

- (void) process;

@end
