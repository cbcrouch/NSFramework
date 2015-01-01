//
//  NFRUtils.h
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#ifdef DEBUG
#define CHECK_GL_ERROR() [NFRUtils checkGLError:__FILE__ line:__LINE__ function:__FUNCTION__]
#else
#define CHECK_GL_ERROR() // no-op when building a release version
#endif

typedef NS_ENUM(NSUInteger, SHADER_TYPE) {
    kVertexShader,
    kFragmentShader,
    kProgram
};

//
// TODO: move NFUtils methods here
//

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
+ (GLuint) createProgramWithVertexSource:(NSString *)vertexSource withFragmentSource:(NSString *)fragmentSource;
+ (void) destroyProgramWithHandle:(GLuint)handle;


+ (GLuint) createUniformBufferNamed:(NSString *)bufferName inProgrm:(GLuint)handle;
+ (void) destroyUniformBufferHandle:(GLuint)handle;

+ (void) setUniformBuffer:(GLuint)hUBO withData:(NSArray *)dataArray inProgrm:(GLuint)handle;


//
// TODO: add a method for drawing a bounding box around an object
//
//+(void) drawBoundingBox:(GLKMatrix4 *)mat;

//
// TODO: add a method for creating an NFAssetData object with an x-z grid and the cardinal axis
//
//+(NFAssetData *) createBaseGrid:(int)size withAxis:(int size);


// VAO utils
+ (void) destroyVaoWithHandle:(GLuint)hVAO;

+ (void) checkGLError:(const char *)file line:(const int)line function:(const char *)function;

// TODO: should be move to NSResourceManager which will contain class methods for loading raw data and instance
//       methods for level stream ??
+ (NSString *) loadShaderSourceWithName:(NSString *)shaderName ofType:(SHADER_TYPE)type;

@end
