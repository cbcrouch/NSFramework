//
//  NFRProgram.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


@protocol NFRProgram <NSObject>

@property (nonatomic, readonly) GLuint hProgram;

//
// TODO: should be upgraded to take a VBO / model matrix array to support hierarchical data
//
- (void) setStateWithVAO:(GLint)hVAO withVBO:(GLint)hVBO;

- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection;

@end


@interface NFRProgram : NSObject
+ (id<NFRProgram>) createProgramObject:(NSString *)programName;
@end
