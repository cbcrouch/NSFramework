//
//  NFSurfaceModel.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

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

//
// TOOD: setup an enum to allow for multiple types of default textures
//
typedef NS_ENUM(NSUInteger, DEFAULT_SURFACES) {
    kTestGrid,
    kTestGridColored,
    kGray127
};

//
// TODO: take a DEFAULT_SURFACES argument and rename to defaultSurfaceModel
//
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

@property (nonatomic, assign) float Tr;      // transparency
@property (nonatomic, assign) GLKVector3 Tf; // transmission factor

@property (nonatomic, assign) NSInteger illum; // illumination model

@property (nonatomic, assign) GLKVector3 Ka; // ambient color
@property (nonatomic, assign) GLKVector3 Kd; // diffuse color
@property (nonatomic, assign) GLKVector3 Ks; // specular color
@property (nonatomic, assign) GLKVector3 Ke; // emissive color

@property (nonatomic, retain) NFDataMap *map_Ka; // ambient color texture map (will be same as diffuse most of the time)
@property (nonatomic, retain) NFDataMap *map_Kd; // diffuse color texture map
@property (nonatomic, retain) NFDataMap *map_Ks; // specular color texture map
@property (nonatomic, retain) NFDataMap *map_Ns; // specular highlight component

@property (nonatomic, retain) NFDataMap *map_Tr; // transparency map

@property (nonatomic, retain) NFDataMap *map_bump;   // bump map
@property (nonatomic, retain) NFDataMap *map_disp;   // displacement map
@property (nonatomic, retain) NFDataMap *map_decalT; // decal texture

@end
