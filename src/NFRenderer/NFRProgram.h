//
//  NFRProgram.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>




@interface NFRBufferAttributes : NSObject

// VAO handle

@end


@interface NFRBuffer : NSObject

//
// TODO: should this be a strong or weak reference ???
//
@property (nonatomic, weak) NFRBufferAttributes* bufferAttributes;

// data pointer
// data size
// data type
// number elements

@end


@interface NFRTexture : NSObject

// data pointer
// data size
// texture format
// width
// height

@end


@interface NFRSampler : NSObject

// wrap s
// wrap t
// mag filter
// min filter

// mip maps

@end



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


@optional

//
// TODO: replace this method with a better mechanism for selecting/abstracting shader subroutines
//
- (void) activateSubroutine:(NSString*)subroutine;

@end


@interface NFRProgram : NSObject
+ (id<NFRProgram>) createProgramObject:(NSString *)programName;
@end
