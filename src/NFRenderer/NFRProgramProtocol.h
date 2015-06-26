//
//  NFRProgramProtocol.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFRResources.h"

@protocol NFRProgram <NSObject>

@property (nonatomic, readonly) GLuint hProgram;

//
// TODO: implement these two methods to have the same behavior as the above two methods
//
- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes;
- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes;


- (void) drawGeometry:(NFRGeometry*)geometry;

- (void) updateModelMatrix:(GLKMatrix4)modelMatrix;
- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection;


@optional

//
// TODO: replace this method with a better mechanism for selecting/abstracting shader subroutines
//
- (void) activateSubroutine:(NSString*)subroutine;

- (void) updateViewPosition:(GLKVector3)viewPosition;

@end
