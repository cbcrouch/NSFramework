//
//  NFSurfaceModel.m
//  NSFramework
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

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        _width = 0;
        _height = 0;
        _format = GL_INVALID_ENUM;
        _type = GL_INVALID_ENUM;
        _size = 0;
        _rowByteSize = 0;
        _data = NULL;
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
            NSAssert(NO, @"ERROR: NFDataMap can NOT load data with an unknown type");
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
            NSAssert(NO, @"ERROR: NFDataMap can NOT load data with an unknown format");
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


@interface NFSurfaceModel()
@end

@implementation NFSurfaceModel

+ (NFSurfaceModel *) defaultModel {
    NFSurfaceModel *surface = [[[NFSurfaceModel alloc] init] autorelease];
    [surface setName:@"NSGLFramework_defaultSurfaceModel"];


#define USE_HARDCODED_TEX 1

    const int width = 4;
    const int height = 4;

#if USE_HARDCODED_TEX
/*
    unsigned char DefaultTexture[] = {
        200, 200, 200, 255,  100, 100, 100, 255,  200, 200, 200, 255,  100, 100, 100, 255,
        100, 100, 100, 255,  200, 200, 200, 255,  100, 100, 100, 255,  200, 200, 200, 255,
        200, 200, 200, 255,  100, 100, 100, 255,  200, 200, 200, 255,  100, 100, 100, 255,
        100, 100, 100, 255,  200, 200, 200, 255,  100, 100, 100, 255,  200, 200, 200, 255
    };
*/

    unsigned char DefaultTexture[] = {
        200,   0,   0, 255,  100, 100, 100, 255,  200, 200, 200, 255,  100, 100, 100, 255,
        100, 100, 100, 255,    0, 200,   0, 255,  100, 100, 100, 255,  200, 200, 200, 255,
        200, 200, 200, 255,  100, 100, 100, 255,    0,   0, 200, 255,  100, 100, 100, 255,
        100, 100, 100, 255,  200, 200, 200, 255,  100, 100, 100, 255,  200, 200,   0, 255
    };

/*
    unsigned char DefaultTexture[] = {
        200,   0,   0, 255,    0, 200,   0, 255,
          0,   0, 200, 255,  200, 200,   0, 255
    };
*/
#else
    unsigned char* DefaultTexture = (unsigned char*)malloc(4 * width * height * sizeof(uint8_t));
    NSAssert(DefaultTexture != NULL, @"failed malloc, out of memory");

    BOOL texFlip = NO;
    for (int h=0; h<height; ++h) {
        for (int w=0; w<width*4; w+=4) {
            if (texFlip) {
                DefaultTexture[h*width*4 + w]     = 100;
                DefaultTexture[h*width*4 + w + 1] = 100;
                DefaultTexture[h*width*4 + w + 2] = 100;
                DefaultTexture[h*width*4 + w + 3] = 255;
            }
            else {
                DefaultTexture[h*width*4 + w]     = 200;
                DefaultTexture[h*width*4 + w + 1] = 200;
                DefaultTexture[h*width*4 + w + 2] = 200;
                DefaultTexture[h*width*4 + w + 3] = 255;
            }
            texFlip = !texFlip;
        }
        texFlip = !texFlip;
    }
#endif

    NFDataMap *diffuse = [[[NFDataMap alloc] init] autorelease];

    CGRect rect = CGRectMake(0.0, 0.0, (float)width, (float)height);
    [diffuse loadWithData:DefaultTexture ofSize:rect ofType:GL_UNSIGNED_BYTE withFormat:GL_RGBA];

#if !USE_HARDCODED_TEX
    free(DefaultTexture);
#endif

    [surface setMap_Kd:diffuse];
    return surface;
}

//
// NOTE: will need to explicitly synthesize properites if all of the
//       acessor methods are overwritten
//
@synthesize map_Ka = _map_Ka;
@synthesize map_Kd = _map_Kd;
@synthesize map_Ks = _map_Ks;
@synthesize map_Ns = _map_Ns;
@synthesize map_Tr = _map_Tr;
@synthesize map_bump = _map_bump;
@synthesize map_disp = _map_disp;
@synthesize map_decalT = _map_decalT;

- (NFDataMap *) map_Ka {
    if(_map_Ka == nil) {
        _map_Ka = [[[NFDataMap alloc] init] autorelease];
    }
    return _map_Ka;
}

- (NFDataMap *) map_Kd {
    if(_map_Kd == nil) {
        _map_Kd = [[[NFDataMap alloc] init] autorelease];
    }
    return _map_Kd;
}

- (NFDataMap *) map_Ks {
    if(_map_Ks == nil) {
        _map_Ks = [[[NFDataMap alloc] init] autorelease];
    }
    return _map_Ks;
}

- (NFDataMap *) map_Ns {
    if(_map_Ns == nil) {
        _map_Ns = [[[NFDataMap alloc] init] autorelease];
    }
    return _map_Ns;
}

- (NFDataMap *) map_Tr {
    if(_map_Tr == nil) {
        _map_Tr = [[[NFDataMap alloc] init] autorelease];
    }
    return _map_Tr;
}

- (NFDataMap *) map_bump {
    if(_map_bump == nil) {
        _map_bump = [[[NFDataMap alloc] init] autorelease];
    }
    return _map_bump;
}

- (NFDataMap *) map_disp {
    if(_map_disp == nil) {
        _map_disp = [[[NFDataMap alloc] init] autorelease];
    }
    return _map_disp;
}

- (NFDataMap *) map_decalT {
    if(_map_decalT == nil) {
        _map_decalT = [[[NFDataMap alloc] init] autorelease];
    }
    return _map_decalT;
}

- (void) setMap_Ka:(NFDataMap *)map_Ka {
    CGRect rect = CGRectMake(0.0, 0.0, map_Ka.width, map_Ka.height);
    [self.map_Ka loadWithData:map_Ka.data ofSize:rect ofType:map_Ka.type withFormat:map_Ka.format];
}

- (void) setMap_Kd:(NFDataMap *)map_Kd {
    CGRect rect = CGRectMake(0.0, 0.0, map_Kd.width, map_Kd.height);
    [self.map_Kd loadWithData:map_Kd.data ofSize:rect ofType:map_Kd.type withFormat:map_Kd.format];
}

- (void) setMap_Ks:(NFDataMap *)map_Ks {
    CGRect rect = CGRectMake(0.0, 0.0, map_Ks.width, map_Ks.height);
    [self.map_Ks loadWithData:map_Ks.data ofSize:rect ofType:map_Ks.type withFormat:map_Ks.format];
}

- (void) setMap_Ns:(NFDataMap *)map_Ns {
    CGRect rect = CGRectMake(0.0, 0.0, map_Ns.width, map_Ns.height);
    [self.map_Ns loadWithData:map_Ns.data ofSize:rect ofType:map_Ns.type withFormat:map_Ns.format];
}

- (void) setMap_Tr:(NFDataMap *)map_Tr {
    CGRect rect = CGRectMake(0.0, 0.0, map_Tr.width, map_Tr.height);
    [self.map_Tr loadWithData:map_Tr.data ofSize:rect ofType:map_Tr.type withFormat:map_Tr.format];
}

- (void) setMap_bump:(NFDataMap *)map_bump {
    CGRect rect = CGRectMake(0.0, 0.0, map_bump.width, map_bump.height);
    [self.map_bump loadWithData:map_bump.data ofSize:rect ofType:map_bump.type withFormat:map_bump.format];
}

- (void) setMap_disp:(NFDataMap *)map_disp {
    CGRect rect = CGRectMake(0.0, 0.0, map_disp.width, map_disp.height);
    [self.map_disp loadWithData:map_disp.data ofSize:rect ofType:map_disp.type withFormat:map_disp.format];
}

- (void) setMap_decalT:(NFDataMap *)map_decalT {
    CGRect rect = CGRectMake(0.0, 0.0, map_decalT.width, map_decalT.height);
    [self.map_decalT loadWithData:map_decalT.data ofSize:rect ofType:map_decalT.type withFormat:map_decalT.format];
}

@end
