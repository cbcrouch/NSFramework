//
//  NFGraphicsToolkit.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>


// (GT) graphics toolkit


typedef NS_ENUM(NSUInteger, DATA_FORMAT) {
    kInteger,
    kUnsignedInt,
    kFloat,
    kDouble,

    kVec2i,
    kVec3i,
    kVec4i,

    kVec2ui,
    kVec3ui,
    kVec4ui,

    kVec2f,
    kVec3f,
    kVec4f,

    kVec2d,
    kVec3d,
    kVec4d,


    //
    // TODO: add support for arrays
    //

    // n, m => 2-4
    // matnxm
    // matn
};


typedef struct NFBufferDesc_t {
    DATA_FORMAT format;
    int stride;
    int offset;
} NFBufferDesc_t;


@interface NFRBuffer : NSObject

//
// TODO: buffer flags will roughly map to static/dynamic/streaming/etc. OpenGL buffer flags
//
//- (void) setData:(void*)pData withSize:(size_t)dataSize withOptions:(BUFFER_FLAGS)options;


//
// TODO: should also consider supporting mapped buffers here
//

@end


//
// TODO: rather than use NFRVertices look into implementing something that works more along the lines
//       of the MTLRenderCommandEncoder protocol
//

// if using the render command encoder concept break out the stages a little more to reduce the confusion
// with calls like setVertexBuffer since it implies you're passing in vertices when actually it can be anything

@interface NFRVertices : NSObject

@property (nonatomic, retain) NFRBuffer *vertexDataBuffer;
@property (nonatomic, retain) NFRBuffer *indexDataBuffer;

- (void) setPoints:(NFBufferDesc_t)buffDesc;
- (void) setColors:(NFBufferDesc_t)buffDesc;
- (void) setNormals:(NFBufferDesc_t)buffDesc;
- (void) setMapCoords:(NFBufferDesc_t)buffDesc withMapIndex:(NSInteger)mapIndex;

//- (void) setIndices:(NFRBuffer*)indexBuffer ofType:(INDEX_TYPE)type withStride:(NSInteger)stride withOffset:(NSInteger)offset;

@end


@interface NFRMesh : NSObject

//@property (nonatomic, retain) NFSurfaceModel *surfaceModel;
@property (nonatomic, retain) NFRVertices *vertices;

//
// TODO: will eventually need ability to link to a transform hierarchy, perform vertex skinning/displacement, etc.
//
//@property (nonatomic, assign) GLKMatrix4 transform;

//- (void) setGeometryMode:(DRAWING_MODE)drawMode;

@end




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

//
// TODO: implement
//

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

//
// TODO: implement
//

@end




@interface GTVertexDescriptor : NSObject

+ (GTVertexDescriptor *) vertexDescriptor;

- (void) reset;

@property (readonly) GTVertexDescriptorArray *attributes;
@property (readonly) GTVertexBufferLayoutDescriptorArray *layouts;

@end





@interface NFGraphicsToolkit : NSObject

@end
