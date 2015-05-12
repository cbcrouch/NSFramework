//
//  NFGraphicsToolkit.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>


// (GT) graphics toolkit


//
// TODO: break out into several files
//


//
// TODO: expand number of pixel formats used
//
typedef NS_ENUM(NSUInteger, GTPixelFormat) {
    kGTPixelFormatInvalid = 0,

    kGTPixelFormatRGBA8Uint,

    kGTPixelFormatDepth32Float,
    kGTPixelFormatStencil8
};



@interface GTVertexAttributeDescriptor : NSObject
typedef NS_ENUM(NSUInteger, GTVertexFormat) {
    kGTVertexFormatInvalid = 0,
    kGTVertexFormatInt     = 1,
    kGTVertexFormatUInt    = 2,
    kGTVertexFormatFloat   = 3,
    kGTVertexFormatDouble  = 4,
    kGTVertexFormatInt2    = 5,
    kGTVertexFormatInt3    = 6,
    kGTVertexFormatInt4    = 7,
    kGTVertexFormatUInt2   = 8,
    kGTVertexFormatUInt3   = 9,
    kGTVertexFormatUInt4   = 10,
    kGTVertexFormatFloat2  = 11,
    kGTVertexFormatFloat3  = 12,
    kGTVertexFormatFloat4  = 13,
    kGTVertexFormatDouble2 = 14,
    kGTVertexFormatDouble3 = 15,
    kGTVertexFormatDouble4 = 16
    //
    // TODO: add support for matrices
    //
    // (n, m = 2 -> 4)
    // matnxm
    // matn
};
@property (nonatomic, assign) GTVertexFormat format;
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) NSUInteger bufferIndex;
@end

@interface GTVertexDescriptorArray : NSObject
- (GTVertexAttributeDescriptor *) objectAtIndexedSubscript:(NSUInteger)index;
- (void) setObject:(GTVertexAttributeDescriptor *)attributeDesc atIndexedSubscript:(NSUInteger)index;
@end

@interface GTVertexBufferLayoutDescriptor : NSObject
typedef NS_ENUM(NSUInteger, GTVertexStepFunction) {
    kGTVertexStepFunctionConstant = 0,
    kGTVertexStepFunctionPerVertex = 1,
    kGTVertexStepFunctionPerInstance = 2
};
@property (nonatomic, assign) GTVertexStepFunction stepFunction;
@property (nonatomic, assign) NSUInteger stepRate;
@property (nonatomic, assign) NSUInteger stride;
@end

@interface GTVertexBufferLayoutDescriptorArray : NSObject
- (GTVertexBufferLayoutDescriptor *) objectAtIndexedSubscript:(NSUInteger)index;
- (void) setObject:(GTVertexBufferLayoutDescriptor *)bufferDesc atIndexedSubscript:(NSUInteger)index;
@end

@interface GTVertexDescriptor : NSObject
+ (GTVertexDescriptor *) vertexDescriptor;

- (void) reset;

@property (readonly) GTVertexDescriptorArray *attributes;
@property (readonly) GTVertexBufferLayoutDescriptorArray *layouts;
@end



@interface GTRenderPipelineColorAttachmentDescriptor : NSObject
typedef NS_ENUM(NSUInteger, GTBlendOperation) {
    kGTBlendOperationAdd             = 0,
    kGTBlendOperationSubtract        = 1,
    kGTBlendOperationReverseSubtract = 2,
    kGTBlendOperationMin             = 3,
    kGTBlendOperationMax             = 4
};

typedef NS_ENUM(NSUInteger, GTBlendFactor) {
    kGTBlendFactorZero = 0,
    kGTBlendFactorOne = 1,
    kGTBlendFactorSourceColor = 2,
    kGTBlendFactorOneMinusSourceColor = 3,
    kGTBlendFactorSourceAlpha = 4,
    kGTBlendFactorOneMinusSourceAlpha = 5,
    kGTBlendFactorDestinationColor = 6,
    kGTBlendFactorOneMinusDestinationColor = 7,
    kGTBlendFactorDestinationAlpha = 8,
    kGTBlendFactorOneMinusDestinationAlpha = 9,
    kGTBlendFactorSourceAlphaSaturated = 10,
    kGTBlendFactorBlendColor = 11,
    kGTBlendFactorOneMinusBlendColor = 12,
    kGTBlendFactorBlendAlpha = 13,
    kGTBlendFactorOneMinusBlendAlpha = 14
};

typedef NS_ENUM(NSUInteger, GTColorWriteMask) {
    kGTColorWriteMaskNone  = 0,
    kGTColorWriteMaskRed   = 0x1 << 3,
    kGTColorWriteMaskGreen = 0x1 << 2,
    kGTColorWriteMaskBlue  = 0x1 << 1,
    kGTColorWriteMaskAlpha = 0x1 << 0,
    kGTColorWriteMaskAll   = 0xf
};

@property (nonatomic, assign) GTPixelFormat pixelFormat;
@property (nonatomic, assign) GTColorWriteMask writeMask;

@property (nonatomic, assign, getter=isBlendingEnabled) BOOL blendingEnabled;
@property (nonatomic, assign) GTBlendOperation alphaBlendOperation;
@property (nonatomic, assign) GTBlendOperation rgbBlendOperation;

@property (nonatomic, assign) GTBlendFactor destinationAlphaBlendFactor;
@property (nonatomic, assign) GTBlendFactor destinationRGBBlendFactor;
@property (nonatomic, assign) GTBlendFactor sourceAlphaBlendFactor;
@property (nonatomic, assign) GTBlendFactor sourceRGBBlendFactor;
@end

@interface GTRenderPipelineColorAttachmentDescriptorArray : NSObject
- (GTRenderPipelineColorAttachmentDescriptor *) objectAtIndexedSubscript:(NSUInteger)index;
- (void) setObject:(GTRenderPipelineColorAttachmentDescriptor *)bufferDesc atIndexedSubscript:(NSUInteger)index;
@end




@protocol GTFunction
typedef NS_ENUM(NSUInteger, GTFunctionType) {
    kGTFunctionTypeVertex = 1,
    kGTFunctionTypeFragment = 2,
    kGTFunctionTypeKernel = 3
};

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) GTFunctionType functionType;

//@property (nonatomic, readonly) id< GTDevice > device;

@property (nonatomic, readonly) NSArray *vertexAttributes;
@end




// forward declare protocols
@protocol GTDevice;


@protocol GTLibrary
typedef NS_ENUM(NSUInteger, GTLibraryError) {
    kGTLibraryErrorUnsupported    = 1,
    kGTLibraryErrorInternal       = 2,
    kGTLibraryErrorCompileFailure = 3,
    kGTLibraryErrorCompileWarning = 4
};

typedef NS_ENUM(NSUInteger, GTRenderPipelineError) {
    kGTRenderPipelineErrorInternal     = 1,
    kGTRenderPipelineErrorUnsupported  = 2,
    kGTRenderPipelineErrorInvalidInput = 3
};

- (id<GTFunction>) newFunctionWithName:(NSString *)functionName;

@property (nonatomic, readonly) NSArray *functionNames;

@property (nonatomic, readonly) id<GTDevice> device;
@property (nonatomic, copy) NSString *label;
@end


//
// TODO: will need to implement compile options to finish GTDevice
//
//@interface GTCompileOptions : NSObject
//@end


@protocol GTCommandQueue
//
// TODO: implement
//
@end




// NFGTResources.h
// - GTBuffer
// - GTResource
// - GTResourceOptions
// - GTTexture
// - GTSamplerState




@protocol GTBuffer
//
// TODO: implement
//
@end

@protocol GTResource
typedef NS_ENUM(NSUInteger, GTPurgeableState) {
    kGTPurgeableStateKeepCurrent = 1,
    kGTPurgeableStateNonVolatile = 2,
    kGTPurgeableStateVolatile = 3,
    kGTPurgeableStateEmpty = 4
};

typedef NS_ENUM(NSUInteger, GTCPUCacheMode) {
    kGTCPUCacheModeDefaultCache  = 0,
    kGTCPUCacheModeWriteCombined = 1
};

typedef NS_ENUM(NSUInteger, GTResourceOptions) {
    kGTResourceOptionCPUCacheModeDefault = kGTCPUCacheModeDefaultCache,
    kGTResourceOptionCPUCacheModeWriteCombined = kGTCPUCacheModeWriteCombined
};

@property (nonatomic, readonly) GTCPUCacheMode cpuCacheMode;

@property (nonatomic, readonly) id<GTDevice> device;
@property (nonatomic, copy) NSString *label;

- (GTPurgeableState) setPurgeableState:(GTPurgeableState)state;
@end


@protocol GTDevice

typedef NS_ENUM(NSUInteger, GTFeatureSet) {
    kGTFeatureSet_v1 = 0
};

typedef NS_ENUM(NSUInteger, GTPipelineOption) {
    kGTPipelineOptionNone           = 0,
    kGTPipelineOptionArgumentInfo   = 1,
    kGTPipelineOptionBufferTypeInfo = 2
};

@property (nonatomic, readonly) NSString *name;

- (BOOL) supportsFeatureSet:(GTFeatureSet)featureSet;

- (id<GTLibrary>) newDefaultLibrary;
- (id<GTLibrary>) newLibraryWithFile:(NSString *)filepath withError:(NSError **)error;

//
// TODO: implement
//
//- (void) newLibraryWithSource:(NSString *)source options:(GTCompileOptions *)options
//            completionHandler:(void (^)(id<GTLibrary> library, NSError *error))completionHandler;

//- (id<GTLibrary>) newLibraryWithSource:(NSString *)source options:(GTCompileOptions *)options error:(NSError **)error;

//- (id<GTLibrary>) newLibraryWithData:(dispatch_data_t)data error:(NSError **)error;


- (id<GTCommandQueue>) newCommandQueue;
- (id<GTCommandQueue>) newCommandQueueWithMaxCommandBufferCount:(NSUInteger)maxCommandBufferCount;


- (id<GTBuffer>) newBufferWithLength:(NSUInteger)length options:(GTResourceOptions)options;
- (id<GTBuffer>) newBufferWithData:(const void *)pointer length:(NSUInteger)length options:(GTResourceOptions)options;
- (id<GTBuffer>) newBufferWithBytesNoCopy:(void *)pointer length:(NSUInteger)length options:(GTResourceOptions)options
                              deallocator:(void (^)(void *pointer, NSUInteger length))deallocator;


//
// TODO: implement texture and sampler classes
//
//- (id<GTTexture>) newTextureWithDescriptor:(GTTextureDescriptor *)descriptor;
//- (id<GTSamplerState>) newSamplerStateWithDescriptor:(GTSamplerDescriptor *)descriptor;

//- (id<GTDepthStencilState>) newDepthStencilStateWithDescriptor:(GTDepthStencilDescriptor *)descriptor;

//- (void) newRenderPipelineStateWithDescriptor:(GTRenderPipelineDescriptor *)descriptor
//                            completionHandler:(void (^)(id<GTRenderPipelineState> renderPipelineState, NSError *error))completionHandler;
//- (void) newRenderPipelineStateWithDescriptor:(GTRenderPipelineDescriptor *)descriptor options:(GTPipelineOption)options
//                            completionHandler:(void (^)(id<GTRenderPipelineState> renderPipelineState, GTRenderPipelineReflection *reflection, NSError *error))completionHandler;
//- (id<GTRenderPipelineState>) newRenderPipelineStateWithDescriptor:(GTRenderPipelineDescriptor *)descriptor error:(NSError **)error;
//- (id<GTRenderPipelineState>) newRenderPipelineStateWithDescriptor:(GTRenderPipelineDescriptor *)descriptor
//                                                           options:(GTPipelineOption)options
//                                                        reflection:(GTRenderPipelineReflection **)reflection
//                                                             error:(NSError **)error;



//
// TODO: determine if it is possible to support compute using OpenCL
//
/*
- (void) newComputePipelineStateWithFunction:(id<GTFunction>)function
                          completionHandler:(void (^)(id<GTComputePipelineState> computePipelineState,
                                                      NSError *error))completionHandler;

- (void) newComputePipelineStateWithFunction:(id<GTFunction>)function
                                    options:(GTPipelineOption)options
                          completionHandler:(void (^)(id<GTComputePipelineState> computePipelineState,
                                                      GTComputePipelineReflection *reflection,
                                                      NSError *error))completionHandler;

- (id<GTComputePipelineState>) newComputePipelineStateWithFunction:(id<GTFunction>)function
                                                             error:(NSError **)error;

- (id<GTComputePipelineState>) newComputePipelineStateWithFunction:(id<GTFunction>)function
                                                           options:(GTPipelineOption)options
                                                        reflection:(GTComputePipelineReflection **)reflection
                                                             error:(NSError **)error;
*/

@end








@interface GTRenderPipelineDescriptor : NSObject

- (void) reset;

//
// TODO: is the color attachment roughly an OpenGL FBO with a singular color attachment and
//       multiple color attachments handled through multiple FBOs ??
//
@property (readonly) GTRenderPipelineColorAttachmentDescriptorArray *colorAttachments;
@property (nonatomic, assign) GTPixelFormat depthAttachmentPixelFormat;
@property (nonatomic, assign) GTPixelFormat stencilAttachmentPixelFormat;

@property (nonatomic, retain, readwrite) id< GTFunction > fragmentFunction;
@property (nonatomic, retain, readwrite) id< GTFunction > vertexFunction;
@property (nonatomic, copy) GTVertexDescriptor *vertexDescriptor;

@property (nonatomic, readwrite, getter=isRasterizationEnabled) BOOL rasterizationEnabled;

@property (nonatomic, readwrite, getter=isAlphaToCoverageEnabled) BOOL alphaToCoverageEnabled;
@property (nonatomic, readwrite, getter=isAlphaToOneEnabled) BOOL alphaToOneEnabled;
@property (nonatomic, readwrite) NSUInteger sampleCount;

@property (nonatomic, copy) NSString *lable;

@end




@interface NFGraphicsToolkit : NSObject

@end
