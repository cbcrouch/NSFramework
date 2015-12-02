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


//typedef void (^processBlock)(void);
//- (processBlock) getProcessBlock;

//@property (nonatomic, retain) NSMutableArray* commandArray;

//- (NSMutableArray*) getCommandArray;

@end


//
// TODO: is there a better way to encode commands for a specific format/program
//       than using specific classes ?? (check Metal API examples)
//

@interface NFRCommandBufferDebug : NSObject <NFRCommandBufferProtcol>

//@property (nonatomic, retain) NSMutableArray* geometryArray;

//- (void) addGeometry:(NFRGeometry*)geometry;

@end


@interface NFRCommandBufferDefault : NSObject <NFRCommandBufferProtcol>

@property (nonatomic, retain) NSMutableArray* geometryArray;
@property (nonatomic, retain) NSMutableArray* lightsArray;

- (void) addGeometry:(NFRGeometry*)geometry;
- (void) addLight:(id<NFLightSource>)light;

@end


@interface NFRCommandBufferDisplay : NSObject <NFRCommandBufferProtcol>

@end



@interface NFRRenderRequest : NSObject

@property (nonatomic, retain) id<NFRProgram> program;
@property (nonatomic, retain) NSMutableArray* geometryArray;
@property (nonatomic, retain) NSMutableArray* lightsArray;

@property (nonatomic, retain) NFRRenderTarget* renderTarget;

- (void) addGeometry:(NFRGeometry*)geometry;
- (void) addLight:(id<NFLightSource>)light;

- (void) process;

@end
