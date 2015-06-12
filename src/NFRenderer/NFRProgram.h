//
//  NFRProgram.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>




//
// TODO: implement the following classes:
//
// - NFRBuffer
// - NFRBufferAttributes (similiar to vertex attributes concept in other APIs)
// - NFRTexture
// - NFRSampler




@protocol NFRProgram <NSObject>

@property (nonatomic, readonly) GLuint hProgram;

- (void) configureInputState:(GLint)hVAO;

- (void) configureVertexBufferLayout:(GLint)hVBO withVAO:(GLint)hVAO;

//
// TODO: update buffer class should take a size and buffer type so they can be collapsed into one call
//
- (void) updateVertexBuffer:(GLint)hVBO numVertices:(GLuint)numVertices dataPtr:(void*)pData;
- (void) updateIndexBuffer:(GLint)hEBO numIndices:(GLuint)numIndices dataPtr:(void*)pData;

- (void) updateModelMatrix:(GLKMatrix4)modelMatrix;
- (void) updateViewMatrix:(GLKMatrix4)viewMatrix projectionMatrix:(GLKMatrix4)projection;

//
// TODO: need a mechanism for selecting which shader subroutines to use
//

//glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &(phongSubroutine));
//glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &(lightSubroutine));

@end


@interface NFRProgram : NSObject
+ (id<NFRProgram>) createProgramObject:(NSString *)programName;
@end
