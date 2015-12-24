//
//  NFRDataMap.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>



// http://www.opengl.org/wiki/Sampler_Object


@interface NFRDataSampler : NSObject


//
// TODO: should class relevant enums be moved inside of the interface ?? what
//       advantage/difference does this provide in ObjC ?? or is it convention ??
//
typedef NS_ENUM(NSUInteger, DATA_MAP_FILTER) {
    kFilterNearest,
    kFilterLinear,
    kFilterNearestMipMapNearest,
    kFilterLinearMipMapNearest,
    kFilterNearestMipMapLinear,
    kFilterLinearMipmapLinear
};


@property (nonatomic, assign) DATA_MAP_FILTER magFilter;
@property (nonatomic, assign) DATA_MAP_FILTER minFilter;

// wrap s
// wrap t

// mipmaps

// anisotropic filtering

// LOD range

// LOD bias

// comparison mode

// edge value sampling

// seamless cubemap per fetching

@end



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
@property (nonatomic, assign, readonly) GLubyte* data;

@property (nonatomic, strong) NFRDataSampler* sampler;

- (void) loadWithData:(GLubyte *)pData ofSize:(CGRect)rect ofType:(GLenum)type withFormat:(GLenum)format;

@end
