//
//  NFRResources.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFCommonTypes.h"
#import "NFSurfaceModel.h"

@protocol NFRProgram;


@interface NFRBufferAttributes : NSObject

@property (nonatomic, assign, readonly) GLuint hVAO;
@property (nonatomic, assign, readonly) NF_VERTEX_FORMAT format;

- (instancetype) init __attribute__((unavailable("ERROR: format must be provided upon initialization")));
- (instancetype) initWithFormat:(NF_VERTEX_FORMAT)format;

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
    kBufferDataTypeNFDebugVertex_t
};

@property (nonatomic, retain, readonly) NFRBufferAttributes* bufferAttributes;

@property (nonatomic, assign, readonly) NFR_BUFFER_TYPE bufferType;
@property (nonatomic, assign, readonly) NFR_BUFFER_DATA_TYPE bufferDataType;
@property (nonatomic, assign, readonly) NSUInteger numberOfElements;
@property (nonatomic, assign, readonly) size_t bufferDataSize;
@property (nonatomic, assign, readonly) void* bufferDataPointer;

@property (nonatomic, assign, readonly) GLuint bufferHandle;

- (instancetype) init __attribute__((unavailable("ERROR: type and attributes must be provided upon initialization")));
- (instancetype) initWithType:(NFR_BUFFER_TYPE)type usingAttributes:(NFRBufferAttributes*)bufferAttributes;

- (void) loadData:(void*)pData ofType:(NFR_BUFFER_DATA_TYPE)dataType numberOfElements:(NSUInteger)numElements;

@end



@interface NFRDataMapGL : NSObject

@property (nonatomic, assign, readonly) GLuint textureID;
@property (nonatomic, retain) NFRDataSampler* sampler;

@property (nonatomic, assign, readonly, getter=isTextureValid) BOOL validTexture;

- (void) syncDataMap:(NFRDataMap*)dataMap;

- (void) activateTexture:(GLint)textureUnitNum withUniformLocation:(GLint)uniformLocation;
- (void) deactivateTexture;

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
