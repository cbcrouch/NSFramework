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

- (void) loadProgramInputPoints;

- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes;
- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes;

//
// TODO: drawGeometry should probably be optional as well (make it so once able to replace with a draw block)
//
- (void) drawGeometry:(NFRGeometry*)geometry;

@optional

- (void) updateViewPosition:(GLKVector3)viewPosition;

- (void) updateModelMatrix:(GLKMatrix4)modelMatrix;
- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection;

@end
