//
//  NFSurfaceModel.m
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFSurfaceModel.h"

#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>

@interface NFDataMap()
@property (nonatomic, assign, readwrite) GLsizei size;
@property (nonatomic, assign, readwrite) GLuint rowByteSize;
@property (nonatomic, assign, readwrite) GLubyte *data;
@end

@implementation NFDataMap
@synthesize width = _width;
@synthesize height = _height;
//
// TODO: determine the best way to support texture depth
//
//@synthesize depth = _depth;

@synthesize size = _size;
@synthesize rowByteSize = _rowByteSize;
@synthesize data = _data;

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        [self setWidth:0];
        [self setWidth:0];
        [self setHeight:0];
        [self setFormat:GL_INVALID_ENUM];
        [self setType:GL_INVALID_ENUM];
        [self setSize:0];
        [self setRowByteSize:0];
        [self setData:NULL];
    }
    return self;
}

- (void) dealloc {
    if ([self data] != NULL) {
        free([self data]);
    }
    [super dealloc];
}

- (void) loadWithData:(GLubyte *)pData ofSize:(CGRect)rect ofType:(GLenum)type withFormat:(GLenum)format {
    [self setWidth:CGRectGetWidth(rect)];
    [self setHeight:CGRectGetHeight(rect)];
    [self setFormat:format];
    [self setType:type];

    //
    // TODO: add support for additional types and formats
    //

    NSInteger typeSize = 0;
    switch (type) {
        case GL_UNSIGNED_BYTE:
            typeSize = sizeof(GLubyte);
            break;

        default:
            NSAssert(false, @"ERROR: NFDataMap can NOT load data with an unknown type");
            break;
    }

    NSInteger componentsPerElt = 0;
    switch (format) {
        case GL_RGBA:
            componentsPerElt = 4;
            break;

        case GL_RGB:
            componentsPerElt = 3;
            break;

        default:
            NSAssert(false, @"ERROR: NFDataMap can NOT load data with an unknown format");
            break;
    }

    [self setRowByteSize:rect.size.width * typeSize * componentsPerElt];
    [self setSize:rect.size.height * [self rowByteSize]];

    GLubyte *pDataCopy = (GLubyte *)malloc([self size]);
    NSAssert(pDataCopy != NULL, @"ERROR: failed to allocate image data buffer");

    memcpy(pDataCopy, pData, [self size]);
    [self setData:pDataCopy];
}

@end



@interface NFDataSampler()
// private properties
@end

@implementation NFDataSampler
@end


@implementation NFSurfaceModel

+ (NFSurfaceModel *) defaultModel {
    NFSurfaceModel *surface = [[[NFSurfaceModel alloc] init] autorelease];

    static unsigned char DefaultTexture[] = {
        255, 255, 255, 255,   128, 128, 128, 255,
        128, 128, 128, 128,   255, 255, 255, 255
    };

    NFDataMap *diffuse = [[[NFDataMap alloc] init] autorelease];
    CGRect rect = CGRectMake(0.0, 0.0, 2.0, 2.0);

    [diffuse loadWithData:DefaultTexture ofSize:rect ofType:GL_UNSIGNED_BYTE withFormat:GL_RGBA];
    [surface setMap_Kd:diffuse];

    return surface;
}

@synthesize name = _name;
@synthesize Ns = _Ns;
@synthesize Ni = _Ni;
@synthesize Tr = _Tr;
@synthesize Tf = _Tf;
@synthesize illum = _illum;
@synthesize Ka = _Ka;
@synthesize Kd = _Kd;
@synthesize Ks = _Ks;
@synthesize Ke = _Ke;
@synthesize map_Ka = _map_Ka;
@synthesize map_Kd = _map_Kd;
@synthesize map_Ks = _map_Ks;
@synthesize map_Ns = _map_Ns;
@synthesize map_Tr = _map_Tr;
@synthesize map_bump = _map_bump;
@synthesize map_disp = _map_disp;
@synthesize map_decalT = _map_decalT;

//
// TODO: override the setters for NFDataMap to copy the raw texture data
//

- (NFDataMap *) map_Kd {
    if(_map_Kd == nil) {
        _map_Kd = [[[NFDataMap alloc] init] autorelease];
    }
    return _map_Kd;
}

- (void) setMap_Kd:(NFDataMap *)map_Kd {
    CGRect rect = CGRectMake(0.0, 0.0, map_Kd.width, map_Kd.height);
    [self.map_Kd loadWithData:map_Kd.data ofSize:rect ofType:map_Kd.type withFormat:map_Kd.format];
}

@end
