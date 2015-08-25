//
//  NFSurfaceModel.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFSurfaceModel.h"


@interface NFSurfaceModel()
@end

@implementation NFSurfaceModel

+ (NFSurfaceModel *) defaultSurfaceModel {
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
        200,   0,   0, 255,   63,  63,  63, 255,  255, 255, 255, 255,   63,  63,  63, 255,
         63,  63,  63, 255,    0, 200,   0, 255,   63,  63,  63, 255,  255, 255, 255, 255,
        255, 255, 255, 255,   63,  63,  63, 255,    0,   0, 200, 255,   63,  63,  63, 255,
         63,  63,  63, 255,  255, 255, 255, 255,   63,  63,  63, 255,  200, 200,   0, 255
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

    NFRDataMap *diffuse = [[[NFRDataMap alloc] init] autorelease];

    CGRect rect = CGRectMake(0.0, 0.0, (float)width, (float)height);
    [diffuse loadWithData:DefaultTexture ofSize:rect ofType:GL_UNSIGNED_BYTE withFormat:GL_RGBA];

#if !USE_HARDCODED_TEX
    free(DefaultTexture);
#endif

    [surface setMap_Kd:diffuse];

    [surface setKa:GLKVector3Make(1.0f, 1.0f, 1.0f)];
    [surface setKd:GLKVector3Make(1.0f, 1.0f, 1.0f)];
    [surface setKs:GLKVector3Make(0.2f, 0.2f, 0.2f)];
    [surface setNs:10.0f];

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

//
// TODO: have a boolean valid property for each public property that will be set to YES when
//       the setter for a given property has been called, can then check if a surface model
//       supports a given illumination model based on which properties have valid data
//

- (NFRDataMap *) map_Ka {
    if(_map_Ka == nil) {
        _map_Ka = [[[NFRDataMap alloc] init] autorelease];
    }
    return _map_Ka;
}

- (NFRDataMap *) map_Kd {
    if(_map_Kd == nil) {
        _map_Kd = [[[NFRDataMap alloc] init] autorelease];
    }
    return _map_Kd;
}

- (NFRDataMap *) map_Ks {
    if(_map_Ks == nil) {
        _map_Ks = [[[NFRDataMap alloc] init] autorelease];
    }
    return _map_Ks;
}

- (NFRDataMap *) map_Ns {
    if(_map_Ns == nil) {
        _map_Ns = [[[NFRDataMap alloc] init] autorelease];
    }
    return _map_Ns;
}

- (NFRDataMap *) map_Tr {
    if(_map_Tr == nil) {
        _map_Tr = [[[NFRDataMap alloc] init] autorelease];
    }
    return _map_Tr;
}

- (NFRDataMap *) map_bump {
    if(_map_bump == nil) {
        _map_bump = [[[NFRDataMap alloc] init] autorelease];
    }
    return _map_bump;
}

- (NFRDataMap *) map_disp {
    if(_map_disp == nil) {
        _map_disp = [[[NFRDataMap alloc] init] autorelease];
    }
    return _map_disp;
}

- (NFRDataMap *) map_decalT {
    if(_map_decalT == nil) {
        _map_decalT = [[[NFRDataMap alloc] init] autorelease];
    }
    return _map_decalT;
}

- (void) setMap_Ka:(NFRDataMap *)map_Ka {
    CGRect rect = CGRectMake(0.0, 0.0, map_Ka.width, map_Ka.height);
    [self.map_Ka loadWithData:map_Ka.data ofSize:rect ofType:map_Ka.type withFormat:map_Ka.format];
}

- (void) setMap_Kd:(NFRDataMap *)map_Kd {
    CGRect rect = CGRectMake(0.0, 0.0, map_Kd.width, map_Kd.height);
    [self.map_Kd loadWithData:map_Kd.data ofSize:rect ofType:map_Kd.type withFormat:map_Kd.format];
}

- (void) setMap_Ks:(NFRDataMap *)map_Ks {
    CGRect rect = CGRectMake(0.0, 0.0, map_Ks.width, map_Ks.height);
    [self.map_Ks loadWithData:map_Ks.data ofSize:rect ofType:map_Ks.type withFormat:map_Ks.format];
}

- (void) setMap_Ns:(NFRDataMap *)map_Ns {
    CGRect rect = CGRectMake(0.0, 0.0, map_Ns.width, map_Ns.height);
    [self.map_Ns loadWithData:map_Ns.data ofSize:rect ofType:map_Ns.type withFormat:map_Ns.format];
}

- (void) setMap_Tr:(NFRDataMap *)map_Tr {
    CGRect rect = CGRectMake(0.0, 0.0, map_Tr.width, map_Tr.height);
    [self.map_Tr loadWithData:map_Tr.data ofSize:rect ofType:map_Tr.type withFormat:map_Tr.format];
}

- (void) setMap_bump:(NFRDataMap *)map_bump {
    CGRect rect = CGRectMake(0.0, 0.0, map_bump.width, map_bump.height);
    [self.map_bump loadWithData:map_bump.data ofSize:rect ofType:map_bump.type withFormat:map_bump.format];
}

- (void) setMap_disp:(NFRDataMap *)map_disp {
    CGRect rect = CGRectMake(0.0, 0.0, map_disp.width, map_disp.height);
    [self.map_disp loadWithData:map_disp.data ofSize:rect ofType:map_disp.type withFormat:map_disp.format];
}

- (void) setMap_decalT:(NFRDataMap *)map_decalT {
    CGRect rect = CGRectMake(0.0, 0.0, map_decalT.width, map_decalT.height);
    [self.map_decalT loadWithData:map_decalT.data ofSize:rect ofType:map_decalT.type withFormat:map_decalT.format];
}

@end
