//
//  NFRUtils.h
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import "NFRProgramProtocol.h"

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
    kGeometryShader,
    kFragmentShader,
    //kComputeShader,
    kProgram
};

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


// render math utils
+ (GLKMatrix4) viewMatrixFromPosition:(GLKVector3)position toDestination:(GLKVector3)destination;


// shader utils
+ (id<NFRProgram>) createProgramObject:(NSString *)programName;

+ (GLuint) createProgram:(NSString *)programName;
+ (void) destroyProgramWithHandle:(GLuint)handle;


+ (GLuint) createUniformBufferNamed:(NSString *)bufferName inProgrm:(GLuint)handle;
+ (void) destroyUniformBufferHandle:(GLuint)handle;

//
// TODO: this currently only works with GLKMatrix4 elements, it should be made more generic if possible
//
+ (void) setUniformBuffer:(GLuint)hUBO withData:(NSArray *)dataArray;


//
// TODO: add a method for drawing a bounding box around an object
//
//+(void) drawBoundingBox:(GLKMatrix4 *)mat;


//+ (void) displaySubroutines:(GLuint)hProgram;


// VAO utils
+ (void) destroyVaoWithHandle:(GLuint)hVAO;

+ (void) checkGLError:(const char *)file line:(const int)line function:(const char *)function;

@end
