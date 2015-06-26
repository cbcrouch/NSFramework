//
//  NFRProgram.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


#import "NFRResources.h"
#import "NFRProgramProtocol.h"


@interface NFRRenderRequest : NSObject

@property (nonatomic, retain) id<NFRProgram> program;
@property (nonatomic, retain) NSMutableArray* geometryArray;

- (void) addGeometry:(NFRGeometry*)geometry;
- (void) process;

@end



@interface NFRProgram : NSObject
+ (id<NFRProgram>) createProgramObject:(NSString *)programName;
@end
