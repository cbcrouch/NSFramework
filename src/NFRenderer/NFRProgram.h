//
//  NFRProgram.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFRDataMap.h"

@protocol NFRProgram;


@interface NFRBufferAttributes : NSObject

// VAO handle

// store values for glVertexAttribPointer

@end


@interface NFRBuffer : NSObject

@property (nonatomic, weak) NFRBufferAttributes* bufferAttributes;

// data pointer
// data size
// data type
// number elements

@end


@interface NFRGeometry : NSObject

//
// TODO: consider making buffers weak properties and when traversing the
//       geometry array in the render request remove geometry objects whose
//       buffer objects are no longer valid
//

@property (nonatomic, retain) NFRBuffer* vertexBuffer;
@property (nonatomic, retain) NFRBuffer* indexBuffer;

@property (nonatomic, retain) NSArray* dataMapArray;

@end


@interface NFRRenderRequest : NSObject

// collection of textures/sampler, buffers, etc. to draw

@property (nonatomic, weak) id<NFRProgram> program;

//
// TODO: the render request should sync the render data types to an OpenGL object cache
//       internal to the render request module ??
//
@property (nonatomic, retain) NSArray* geometryArray;

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
// TODO: add an optional NFRTexture array ???
//


//
// TODO: replace this method with a better mechanism for selecting/abstracting shader subroutines
//
- (void) activateSubroutine:(NSString*)subroutine;

- (void) updateViewPosition:(GLKVector3)viewPosition;

@end


@interface NFRProgram : NSObject
+ (id<NFRProgram>) createProgramObject:(NSString *)programName;
@end
