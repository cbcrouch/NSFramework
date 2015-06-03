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




@interface GTRenderPassAttachmentDescriptor : NSObject <NSObject, NSCopying>

typedef NS_ENUM(NSUInteger, GTLoadAction) {
    kGTLoadActionDontCare = 0,
    kGTLoadActionLoad = 1,
    kGTLoadActionClear = 2
};

typedef NS_ENUM(NSUInteger, GTStoreAction) {
    kGTStoreActionDontCare = 0,
    kGTStoreActionStore = 1,
    kGTStoreActionMultisampleResolve = 2
};

@property (nonatomic, strong) id<GTTexture> texture;
@property (nonatomic, assign) NSUInteger level;
@property (nonatomic, assign) NSUInteger slice;
@property (nonatomic, assign) NSUInteger depthPlane;

@property (nonatomic, assign) GTLoadAction loadAction;
@property (nonatomic, assign) GTStoreAction storeAction;

@property (nonatomic, strong) id<GTTexture> resolveTexture;
@property (nonatomic, assign) NSUInteger resolveLevel;
@property (nonatomic, assign) NSUInteger resolveSlice;
@property (nonatomic, assign) NSUInteger resolveDepthPlane;

@end


@interface GTRenderPassColorAttachmentDescriptor : GTRenderPassAttachmentDescriptor <NSObject, NSCopying>
@property (nonatomic) GTClearColor clearColor;
@end


@interface GTRenderPassDepthAttachmentDescriptor : GTRenderPassAttachmentDescriptor <NSObject, NSCopying>
@property (nonatomic) double clearDepth;
@end

@interface GTRenderPassStencilAttachmentDescriptor : GTRenderPassAttachmentDescriptor <NSObject, NSCopying>
@property (nonatomic) uint32_t clearStencil;
@end



@interface GTRenderPassColorAttachmentDescriptorArray : NSObject <NSObject>
- (GTRenderPassColorAttachmentDescriptor*) objectAtIndexedSubscript:(NSUInteger)attachmentIndex;
- (void) setObject:(GTRenderPassColorAttachmentDescriptor*)attachment atIndexedSubscript:(NSUInteger)attachmentIndex;
@end



@interface GTRenderPassDescriptor : NSObject <NSObject, NSCopying>

@property (nonatomic, readonly) GTRenderPassColorAttachmentDescriptorArray* colorAttachments;

@property (nonatomic, copy) GTRenderPassDepthAttachmentDescriptor* depthAttachment;
@property (nonatomic, copy) GTRenderPassStencilAttachmentDescriptor* stencilAttachment;

@property (nonatomic, strong) id<GTBuffer> visibilityResultBuffer;

+ (GTRenderPassDescriptor*) renderPassDescriptor;

@end




// https://developer.apple.com/library/prerelease/ios/documentation/Metal/Reference/MTLCommandBuffer_Ref/index.html

@protocol GTCommandBuffer <NSObject>

typedef NS_ENUM(NSUInteger, GTCommandBufferStatus) {
    kGTCommandBufferStatusNotEnqueued = 0,
    kGTCommandBufferStatusEnqueued = 1,
    kGTCommandBufferStatusCommitted = 2,
    kGTCommandBufferStatusScheduled = 3,
    kGTCommandBufferStatusCompleted = 4,
    kGTCommandBufferStatusError = 5
};

typedef NS_ENUM(NSUInteger, GTCommandBufferError) {
    kGTCommandBufferErrorNone = 0,
    kGTCommandBufferErrorInternal = 1,
    kGTCommandBufferErrorTimeout = 2,
    kGTCommandBufferErrorPageFault = 3,
    kGTCommandBufferErrorBlacklisted = 4,
    kGTCommandBufferErrorNotPermitted = 7,
    kGTCommandBufferErrorOutOfMemory = 8,
    kGTCommandBufferErrorInvalidResource = 9
};

typedef void (^GTCommandBufferHandler)(id <GTCommandBuffer> buffer);


//
// TODO: implement
//

// creating command encoders
- (id<GTRenderCommandEncoder>) renderCommandEncoderWithDescriptor:(GTRenderPassDescriptor *)renderPassDescriptor;



// scheduling and executing commands

// monitoring command buffere execution

// determing whether to keep strong references to associated objects

// identifying the command buffer

@end



@protocol GTCommandQueue <NSObject>

@property (nonatomic, copy) NSString* label;
@property (nonatomic, readonly) id<GTDevice> device;

- (id<GTCommandBuffer>) commandBuffer;
- (id<GTCommandBuffer>) commandBufferWithUnretainedReferences;

@end





@interface NFGTCommands : NSObject

@end
