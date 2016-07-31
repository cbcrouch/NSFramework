//
//  NFRResources.h
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFCommonTypes.h"
#import "NFSurfaceModel.h"


//
// TODO: break out all these classes into their own header and source files
//


@protocol NFRProgram;

//
// TODO: rename to something like NFRState and migrate all state to it, then when geometry, etc.
//       is added to the command list it takes a copy of the state object
//
@interface NFRBufferAttributes : NSObject

@property (nonatomic, assign, readonly) GLuint hVAO;
@property (nonatomic, assign, readonly) NF_VERTEX_FORMAT format;

- (instancetype) init __attribute__((unavailable("ERROR: format must be provided upon initialization")));
- (instancetype) initWithFormat:(NF_VERTEX_FORMAT)format NS_DESIGNATED_INITIALIZER;

@end


@interface NFRBuffer : NSObject

typedef NS_ENUM(NSUInteger, NFR_BUFFER_TYPE) {
    kBufferTypeVertex,
    kBufferTypeIndex
};

//
// TODO: try and consolidate around a single vertex type enum
//
typedef NS_ENUM(NSUInteger, NFR_BUFFER_DATA_TYPE) {
    kBufferDataTypeUnknown,
    kBufferDataTypeUShort,
    kBufferDataTypeNFVertex_t,
    kBufferDataTypeNFDebugVertex_t,
    kBufferDataTypeNFScreenSpaceVertex_t
};

@property (nonatomic, strong, readonly) NFRBufferAttributes* bufferAttributes;

@property (nonatomic, assign, readonly) NFR_BUFFER_TYPE bufferType;
@property (nonatomic, assign, readonly) NFR_BUFFER_DATA_TYPE bufferDataType;
@property (nonatomic, assign, readonly) NSUInteger numberOfElements;
@property (nonatomic, assign, readonly) size_t bufferDataSize;
@property (nonatomic, assign, readonly) void* bufferDataPointer;

@property (nonatomic, assign, readonly) GLuint bufferHandle;

- (instancetype) init __attribute__((unavailable("ERROR: type and attributes must be provided upon initialization")));
- (instancetype) initWithType:(NFR_BUFFER_TYPE)type usingAttributes:(NFRBufferAttributes*)bufferAttributes NS_DESIGNATED_INITIALIZER;

- (void) loadData:(void*)pData ofType:(NFR_BUFFER_DATA_TYPE)dataType numberOfElements:(NSUInteger)numElements;

@end


@interface NFRCubeMapGL : NSObject

@property (nonatomic, assign, readonly) GLuint textureID;

@property (nonatomic, assign, readonly, getter=isTextureValid) BOOL validTexture;

- (void) syncCubeMap:(NFRCubeMap*)cubeMap;

- (void) activateTexture:(GLint)textureUnitNum withUniformLocation:(GLint)uniformLocation;
- (void) deactivateTexture;

@end


@interface NFRDataMapGL : NSObject

@property (nonatomic, assign, readonly) GLuint textureID;
@property (nonatomic, strong) NFRDataSampler* sampler;

@property (nonatomic, assign, readonly, getter=isTextureValid) BOOL validTexture;

- (void) syncDataMap:(NFRDataMap*)dataMap;

- (void) activateTexture:(GLint)textureUnitNum withUniformLocation:(GLint)uniformLocation;
- (void) deactivateTexture;

@end


@interface NFRGeometry : NSObject

@property (nonatomic, strong) NFRBuffer* vertexBuffer;
@property (nonatomic, strong) NFRBuffer* indexBuffer;
@property (nonatomic, strong) NFSurfaceModel* surfaceModel;

@property (nonatomic, assign) GLenum mode;
@property (nonatomic, assign) GLKMatrix4 modelMatrix;

@property (nonatomic, strong, readonly) NSMutableDictionary* textureDictionary;

- (void) syncSurfaceModel;
- (void) assignCubeMap:(NFRCubeMap*)cubeMap;

@end
