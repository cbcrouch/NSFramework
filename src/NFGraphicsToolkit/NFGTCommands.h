//
//  NFGTCommands.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFGTDataTypes.h"

@protocol GTDevice;
@protocol GTDepthStencilState;
@protocol GTRenderPipelineState;
@protocol GTBuffer;
@protocol GTSamplerState;
@protocol GTTexture;


@protocol GTCommandEncoder <NSObject>

@property (nonatomic, copy) NSString* label;
@property (nonatomic, readonly) id<GTDevice> device;

- (void) endEncoding;

@end


@protocol GTRenderCommandEncoder <GTCommandEncoder>

typedef NS_ENUM(NSUInteger, GTPrimitiveType) {
    kGTPrimitiveTypePoint = 0,
    kGTPrimitiveTypeLine = 1,
    kGTPrimitiveTypeLineStrip = 2,
    kGTPrimitiveTypeTriangle = 3,
    kGTPrimitiveTypeTriangleStrip = 4
};

typedef NS_ENUM(NSUInteger, GTIndexType) {
    kGTIndexTypeUInt16 = 0,
    kGTIndexTypeUInt32 = 1
};

typedef NS_ENUM(NSUInteger, GTVisibilityResultMode) {
    kGTVisibilityResultModeDisabled = 0,
    kGTVisibilityResultModeBoolean = 1
};

typedef NS_ENUM(NSUInteger, GTCullMode) {
    kGTCullModeNone = 0,
    kGTCullModeFront = 1,
    kGTCullModeBack = 2
};

typedef NS_ENUM(NSUInteger, GTWinding) {
    kGTWindingClockwise = 0,
    kGTWindingCounterClockwise = 1
};

typedef NS_ENUM(NSUInteger, GTTriangleFillMode) {
    kGTTriangleFillModeFill = 0,
    kGTTriangleFillModeLines = 1
};


// setting graphics rendering state
- (void) setBlendColorRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
- (void) setCullMode:(GTCullMode)cullMode;
- (void) setDepthBias:(float)depthBias slopeScale:(float)slopeScale clamp:(float)clamp;
- (void) setDepthStencilState:(id<GTDepthStencilState>)depthStencilState;
- (void) setFrontFacingWinding:(GTWinding)frontFacingWinding;
- (void) setRenderPipelineState:(id<GTRenderPipelineState>)pipelineState;
- (void) setScissorRect:(GTScissorRect)rect;
- (void) setStencilReferenceValue:(uint32_t)ref;
- (void) setTriangleFillMode:(GTTriangleFillMode)fillMode;
- (void) setViewport:(GTViewport)viewport;
- (void) setVisibilityResultMode:(GTVisibilityResultMode)mode offset:(NSUInteger)offset;

// specifying resources for a vertex function
- (void) setVertexBuffer:(id<GTBuffer>)buffer offset:(NSUInteger)offset atIndex:(NSUInteger)index;
- (void) setVertexBuffers:(const id<GTBuffer> [])buffers offsets:(const NSUInteger [])offsets withRange:(NSRange)range;
- (void) setVertexBufferOffset:(NSUInteger)offset atIndex:(NSUInteger)index;
- (void) setVertexBytes:(const void *)bytes length:(NSUInteger)length atIndex:(NSUInteger)index;
- (void) setVertexSamplerState:(id<GTSamplerState>)sampler atIndex:(NSUInteger)index;
- (void) setVertexSamplerStates:(const id<GTSamplerState> [])samplers withRange:(NSRange)range;
- (void) setVertexSamplerState:(id<GTSamplerState>)sampler lodMinClamp:(float)lodMinClamp lodMaxClamp:(float)lodMaxClamp atIndex:(NSUInteger)index;
- (void) setVertexSamplerStates:(const id<GTSamplerState> [])samplers lodMinClamps:(const float [])lodMinClamps lodMaxClamps:(const float [])lodMaxClamps withRange:(NSRange)range;
- (void) setVertexTexture:(id<GTTexture>)texture atIndex:(NSUInteger)index;
- (void) setVertexTextures:(const id<GTTexture> [])textures withRange:(NSRange)range;

// specifying resources for a fragment function
- (void) setFragmentBuffer:(id<GTBuffer>)buffer offset:(NSUInteger)offset atIndex:(NSUInteger)index;
- (void) setFragmentBuffers:(const id<GTBuffer> [])buffers offsets:(const NSUInteger [])offsets withRange:(NSRange)range;
- (void) setFragmentBufferOffset:(NSUInteger)offset atIndex:(NSUInteger)index;
- (void) setFragmentBytes:(const void *)bytes length:(NSUInteger)length atIndex:(NSUInteger)index;
- (void) setFragmentSamplerState:(id<GTSamplerState>)sampler atIndex:(NSUInteger)index;
- (void) setFragmentSamplerStates:(const id<GTSamplerState> [])samplers withRange:(NSRange)range;
- (void) setFragmentSamplerState:(id<GTSamplerState>)sampler lodMinClamp:(float)lodMinClamp lodMaxClamp:(float)lodMaxClamp atIndex:(NSUInteger)index;
- (void) setFragmentSamplerStates:(const id<GTSamplerState> [])samplers lodMinClamps:(const float [])lodMinClamps lodMaxClamps:(const float [])lodMaxClamps withRange:(NSRange)range;
- (void) setFragmentTexture:(id<GTTexture>)texture atIndex:(NSUInteger)index;
- (void) setFragmentTextures:(const id<GTTexture> [])textures withRange:(NSRange)range;

// drawing geometric primitives
- (void) drawPrimitives:(GTPrimitiveType)primitiveType vertexStart:(NSUInteger)vertexStart vertexCount:(NSUInteger)vertexCount instanceCount:(NSUInteger)instanceCount;
- (void) drawPrimitives:(GTPrimitiveType)primitiveType vertexStart:(NSUInteger)vertexStart vertexCount:(NSUInteger)vertexCount;

- (void) drawIndexedPrimitives:(GTPrimitiveType)primitiveType
                    indexCount:(NSUInteger)indexCount
                     indexType:(GTIndexType)indexType
                   indexBuffer:(id<GTBuffer>)indexBuffer
             indexBufferOffset:(NSUInteger)indexBufferOffset
                 instanceCount:(NSUInteger)instanceCount;

- (void) drawIndexedPrimitives:(GTPrimitiveType)primitiveType
                    indexCount:(NSUInteger)indexCount
                     indexType:(GTIndexType)indexType
                   indexBuffer:(id<GTBuffer>)indexBuffer
             indexBufferOffset:(NSUInteger)indexBufferOffset;

@end



@protocol GTCommandBuffer <NSObject>

//
// TODO: implement
//

@end



@protocol GTCommandQueue <NSObject>

@property (nonatomic, copy) NSString* label;
@property (nonatomic, readonly) id<GTDevice> device;

- (id<GTCommandBuffer>) commandBuffer;
- (id<GTCommandBuffer>) commandBufferWithUnretainedReferences;

@end





@interface NFGTCommands : NSObject

@end
