//
//  NFGraphicsToolkit.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>




//
// TOOD: need to move this out of the NFRUtils (which should strictly remain OpenGL utility functions) and
//       into a renderer abstraction layer
//

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








@interface NFGraphicsToolkit : NSObject

@end
