//
//  NFRDataMap.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// TODO: should expand NFDataMap to support cube map textures, array textures, and buffer textures
//

@interface NFRDataMap : NSObject

@property (nonatomic, assign) GLuint width;
@property (nonatomic, assign) GLuint height;

//
// TODO: determine the best way to support texture depth
//
//@property (nonatomic, assign) GLuint depth;

//
// TODO: to better generalize NFDataMap could store bits per component and components per
//       element instead of the format and type (and one step further would be support for
//       planar data e.g. IYUV)
//
@property (nonatomic, assign) GLenum format;
@property (nonatomic, assign) GLenum type;

//example format: GL_RGBA
//example type: GL_UNSIGNED_BYTE

@property (nonatomic, assign, readonly) GLsizei size;
@property (nonatomic, assign, readonly) GLuint rowByteSize;
@property (nonatomic, assign, readonly) GLubyte *data;

- (void) loadWithData:(GLubyte *)pData ofSize:(CGRect)rect ofType:(GLenum)type withFormat:(GLenum)format;

@end


// http://www.opengl.org/wiki/Sampler_Object

@interface NFRDataSampler : NSObject

//
// TODO: need a good enum for selecting which GLSL texture access function to use
//
// texture lookup function (either texel fetch or texture)
// texel fetch uses explicit coordinates where as texture uses normalized coordinates and handles filtering

// enum TEXEL_FETCH_MODE
// kTexelFetchNormalized // default
// kTexelFetchExplicit


// wrap s
// wrap t
// mag filter
// min filter

//
// TODO: add support for generating mipmaps
//


// filtering

// - GL_NEAREST
// - GL_LINEAR
// - GL_NEAREST_MIPMAP_NEAREST
// - GL_LINEAR_MIPMAP_NEAREST
// - GL_NEAREST_MIPMAP_LINEAR
// - GL_LINEAR_MIPMAP_LINEAR

// anisotropic filtering

// LOD range

// LOD bias

// comparison mode

// edge value sampling

// border color (shouldn't expose or use)

// seamless cubemap per fetching

@end
