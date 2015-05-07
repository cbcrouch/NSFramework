//
//  NFRUtils.h
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

// check, print, and clear all OpenGL errors
#ifdef DEBUG
#   define CHECK_GL_ERROR() [NFRUtils checkGLError:__FILE__ line:__LINE__ function:__FUNCTION__]
#else
#   define CHECK_GL_ERROR()
#endif

// an OpenGL assert to break on a failure
#ifdef DEBUG
#   define GL(line) do { \
        line; \
        assert(glGetError() == GL_NO_ERROR); \
    } while(0);
#else
#   define GL(line) line
#endif
// usage:
// GL(glClear(GL_COLORS_MASK));
// GL(pos_loc = glGetAttribLocation(prog, "pos"));


typedef NS_ENUM(NSUInteger, SHADER_TYPE) {
    kVertexShader,

    //kTessControlShader,
    //kTessEvaluationShader,
    //kGeometryShader,

    kFragmentShader,

    //kComputeShader,

    kProgram
};


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







// NFRUBO_t
// - blockIndex
// - blockSize
// - numBlocks
// - elementSize
// - hUBO


@interface NFRUtils : NSObject

// NOTE: using all class methods as the OpenGL state machine is considered global across the application
//       (add some more words about how class methods, particuarly utility methods, work well with this notion
//       of global state - may want to quote the common mistakes addressing this on the OpenGL wiki)


// shader utils
+ (GLuint) createProgram:(NSString *)programName;
+ (void) destroyProgramWithHandle:(GLuint)handle;


+ (GLuint) createUniformBufferNamed:(NSString *)bufferName inProgrm:(GLuint)handle;
+ (void) destroyUniformBufferHandle:(GLuint)handle;

+ (void) setUniformBuffer:(GLuint)hUBO withData:(NSArray *)dataArray inProgrm:(GLuint)handle;


//
// TODO: add a method for drawing a bounding box around an object
//
//+(void) drawBoundingBox:(GLKMatrix4 *)mat;


//+ (void) displaySubroutines:(GLuint)hProgram;


// VAO utils
+ (void) destroyVaoWithHandle:(GLuint)hVAO;

+ (void) checkGLError:(const char *)file line:(const int)line function:(const char *)function;

@end
