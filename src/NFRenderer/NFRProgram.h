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

- (instancetype) init __attribute__((unavailable("ERROR: format must be provided upon initialization")));
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

@property (nonatomic, retain, readonly) NFRBufferAttributes* bufferAttributes;

@property (nonatomic, assign, readonly) NFR_BUFFER_TYPE bufferType;
@property (nonatomic, assign, readonly) NFR_BUFFER_DATA_TYPE bufferDataType;
@property (nonatomic, assign, readonly) NSUInteger numberOfElements;
@property (nonatomic, assign, readonly) size_t bufferDataSize;
@property (nonatomic, assign, readonly) void* bufferDataPointer;

- (instancetype) init __attribute__((unavailable("ERROR: type and attributes must be provided upon initialization")));
- (instancetype) initWithType:(NFR_BUFFER_TYPE)type usingAttributes:(NFRBufferAttributes*)bufferAttributes;

- (void) loadData:(void*)pData ofType:(NFR_BUFFER_DATA_TYPE)dataType numberOfElements:(NSUInteger)numElements;

@end


@interface NFRGeometry : NSObject

@property (nonatomic, retain) NFRBuffer* vertexBuffer;
@property (nonatomic, retain) NFRBuffer* indexBuffer;
@property (nonatomic, retain) NFSurfaceModel* surfaceModel;

@property (nonatomic, assign) GLenum mode;
@property (nonatomic, assign) GLKMatrix4 modelMatrix;

@property (nonatomic, retain, readonly) NSMutableDictionary* textureDictionary;

- (void) syncSurfaceModel;

@end


@protocol NFRProgram <NSObject>

@property (nonatomic, readonly) GLuint hProgram;


- (void) configureInputState:(GLint)hVAO;
- (void) configureVertexBufferLayout:(GLint)hVBO withVAO:(GLint)hVAO;

//
// TODO: implement these two methods to have the same behavior as the above two methods
//
- (void) configureVertexInput:(NFRBufferAttributes*)bufferAttributes;
- (void) configureVertexBufferLayout:(NFRBuffer*)vertexBuffer withAttributes:(NFRBufferAttributes*)bufferAttributes;



//
// TODO: update buffer class should take a size and buffer type so they can be collapsed into one call
//
- (void) updateVertexBuffer:(GLint)hVBO numVertices:(GLuint)numVertices dataPtr:(void*)pData;
- (void) updateIndexBuffer:(GLint)hEBO numIndices:(GLuint)numIndices dataPtr:(void*)pData;


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


@interface NFRProgram : NSObject
+ (id<NFRProgram>) createProgramObject:(NSString *)programName;
@end


@interface NFRRenderRequest : NSObject

@property (nonatomic, retain) id<NFRProgram> program;
@property (nonatomic, retain) NSMutableArray* geometryArray;

- (void) addGeometry:(NFRGeometry*)geometry;
- (void) process;

@end
