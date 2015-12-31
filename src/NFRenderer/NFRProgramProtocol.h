//
//  NFRProgramProtocol.h
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFRResources.h"


@protocol NFRProgram <NSObject>

@property (nonatomic, readonly) GLuint hProgram;

- (void) loadProgramInputPoints;

- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes;
- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes;

@optional

- (void) drawGeometry:(NFRGeometry*)geometry;

- (void) updateViewPosition:(GLKVector3)viewPosition;

- (void) updateModelMatrix:(GLKMatrix4)modelMatrix;
- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection;

@end
