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
// TODO: add a vertex buffer object that encapsulates VBO and possible VAO state
//


// vertices
// colors
// normals
// mapCoords


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




//#define NFLOATS_POS 4
//#define NFLOATS_NORM 4
//#define NFLOATS_TEX 3

//
// NOTE: this is VBO state which is saved in the VAO
//
/*
glVertexAttribPointer(state.vertAttrib, NFLOATS_POS, GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                      (const GLvoid *)0x00 + offsetof(NFVertex_t, pos));
glVertexAttribPointer(state.normAttrib, NFLOATS_NORM, GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                      (const GLvoid *)0x00 + offsetof(NFVertex_t, norm));
glVertexAttribPointer(state.texAttrib, NFLOATS_TEX, GL_FLOAT, GL_FALSE, sizeof(NFVertex_t),
                      (const GLvoid *)0x00 + offsetof(NFVertex_t, texCoord));
*/



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
