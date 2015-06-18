//
//  NFRProgram.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFSurfaceModel.h"
#import "NFRDataMap.h"

@protocol NFRProgram;


@interface NFRBufferAttributes : NSObject

typedef NS_ENUM(NSUInteger, NFR_VERTEX_FORMAT) {
    kVertexFormatDefault,
    kVertexFormatDebug
};

@property (nonatomic, assign, readonly) GLuint hVAO;
@property (nonatomic, assign, readonly) NFR_VERTEX_FORMAT format;

//
// TODO: prevent a nake init from getting called for now
//
- (instancetype) initWithFormat:(NFR_VERTEX_FORMAT)format;

@end


@interface NFRBuffer : NSObject

typedef NS_ENUM(NSUInteger, NFR_BUFFER_TYPE) {
    kBufferTypeVertex,
    kBufferTypeIndex
};

typedef NS_ENUM(NSUInteger, NFR_BUFFER_DATA_TYPE) {
    kBufferDataTypeUShort,
    kBufferDataTypeNFVertex_t,
    kBufferDataTypeNFDebugVertex_t
};

@property (nonatomic, assign, readonly) NFR_BUFFER_TYPE bufferType;
@property (nonatomic, assign, readonly) NFR_BUFFER_DATA_TYPE bufferDataType;
@property (nonatomic, assign, readonly) NSUInteger numberOfElements;
@property (nonatomic, assign, readonly) size_t bufferDataSize;
@property (nonatomic, assign, readonly) void* bufferDataPointer;

//
// TODO: prevent a naked init from getting called for now
//
- (instancetype) initWithType:(NFR_BUFFER_TYPE)type;

@end


@interface NFRGeometry : NSObject

@property (nonatomic, retain) NFRBufferAttributes* bufferAttributes;

@property (nonatomic, retain) NFRBuffer* vertexBuffer;
@property (nonatomic, retain) NFRBuffer* indexBuffer;

@property (nonatomic, retain) NFSurfaceModel* surfaceModel;

@property (nonatomic, retain, readonly) NSDictionary* textureDictionary;

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
