//
//  NFSurfaceModel.h
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//


#import <Foundation/Foundation.h>


//
// TODO: move data map functionality into NFRCommonTypes.h or something similar so that other
//       modules don't have to include all of the surface model class
//
typedef struct MapCoord3f_t {
    float u;
    float v;

    // TODO: cleanup quote from OpenGL documentation and explain the difference between extra texture params
    //       that OpenGL is expecting and what is defined in the Wavefront obj specification

    // The size of the vec type of texCoord​ depends on the dimensionality of sampler​. A 1D sampler takes a "float", 2D
    // samplers take "vec2", etc. Array samplers add one additional coordinate for the array level to sample. Shadow
    // samplers add one additional coordinate for the sampler comparison value. Array and shadow samplers add two
    // coordinates: the array level followed by the comparison value. So vec when used with a sampler1DArrayShadow is
    // a "vec3".

    float w; // Wavefront obj format allows for a w coord (texture depth, default = 0.0)
} MapCoord3f_t;

// NOTE: OpenGL texture coordinates usually use (S, T, R) may be worth adopting this convention to avoid
//       overloading the "w" component



//
// TODO: should expand NFDataMap to support cube map textures, array textures, and buffer textures
//

@interface NFDataMap : NSObject

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

//
// TODO: add support for generating mipmaps
//

@property (nonatomic, assign, readonly) GLsizei size;
@property (nonatomic, assign, readonly) GLuint rowByteSize;
@property (nonatomic, assign, readonly) GLubyte *data;

- (void) loadWithData:(GLubyte *)pData ofSize:(CGRect)rect ofType:(GLenum)type withFormat:(GLenum)format;

@end


// http://www.opengl.org/wiki/Sampler_Object

@interface NFDataSampler : NSObject

//
// TODO: need a good enum for selecting which GLSL texture access function to use
//
// texture lookup function (either texel fetch or texture)
// texel fetch uses explicit coordinates where as texture uses normalized coordinates and handles filtering

// enum TEXEL_FETCH_MODE
// kTexelFetchNormalized // default
// kTexelFetchExplicit


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


//
// TODO: create classes grouped by common function and pipeline stage that caputre global state
//

// occlusion mode
// culling mode
// .etc



//
// TODO: NFSurfaceModel should be a protocol so that NFWavefrontModel, NFGLModel, and NFPBRModel classes
//       could both be used in the same way when rendering an NFAssetData object
//


@interface NFSurfaceModel : NSObject

+ (NFSurfaceModel *) defaultModel;

@property (nonatomic, retain) NSString *name;

@property (nonatomic, assign) float Ns; // specular coefficient
@property (nonatomic, assign) float Ni; // optical density (also known as index of refraction)

//
// TODO: work out correct format of dissolve factor
//
// dissolve factor e.g. d -halo 0.0 or d 0.0
//@property (nonatomic, assign) float d;
//@property (nonatomic, assign) BOOL dHalo;

@property (nonatomic, assign) float Tr; // transparency

@property (nonatomic, retain) NSArray *Tf; // transmission factor

@property (nonatomic, assign) NSInteger illum; // illumination model

@property (nonatomic, retain) NSArray *Ka; // ambient color
@property (nonatomic, retain) NSArray *Kd; // diffuse color
@property (nonatomic, retain) NSArray *Ks; // specular color

@property (nonatomic, retain) NSArray *Ke; // emissive color

@property (nonatomic, retain) NFDataMap *map_Ka; // ambient color texture map (will be same as diffuse most of the time)
@property (nonatomic, retain) NFDataMap *map_Kd; // diffuse color texture map
@property (nonatomic, retain) NFDataMap *map_Ks; // specular color texture map
@property (nonatomic, retain) NFDataMap *map_Ns; // specular highlight component

@property (nonatomic, retain) NFDataMap *map_Tr; // transparency map

@property (nonatomic, retain) NFDataMap *map_bump;
@property (nonatomic, retain) NFDataMap *map_disp;
@property (nonatomic, retain) NFDataMap *map_decalT;

@end
