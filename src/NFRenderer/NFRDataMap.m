//
//  NFRDataMap.m
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import "NFRDataMap.h"

#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>


@interface NFRCubeMap()
@property (nonatomic, assign, readwrite) GLsizei size;
@property (nonatomic, assign, readwrite) GLuint rowByteSize;
@property (nonatomic, assign, readwrite) GLubyte **data;
@end


@implementation NFRCubeMap

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
    if (self.data != NULL) {
        for (int i=0; i<6; ++i) {
            if (_data[i] != NULL) {
                free(_data[i]);
            }
        }
        _data = NULL;
    }
}

- (void) loadFace:(GLint)faceIndex withData:(GLubyte *)pData ofSize:(CGRect)rect ofType:(GLenum)type withFormat:(GLenum)format {
    self.width = CGRectGetWidth(rect);
    self.height = CGRectGetHeight(rect);
    self.format = format;
    self.type = type;

    //
    // TODO: add support for additional types and formats
    //

    NSInteger typeSize = 0;
    switch (type) {
        case GL_UNSIGNED_BYTE:
            typeSize = sizeof(GLubyte);
            break;

        default:
            NSAssert(nil, @"ERROR: NFDataMap can NOT load data with an unknown type");
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
            NSAssert(nil, @"ERROR: NFDataMap can NOT load data with an unknown format");
            break;
    }

    self.rowByteSize = rect.size.width * typeSize * componentsPerElt;
    self.size = rect.size.height * self.rowByteSize;

    if (!self.data) {
        self.data = (GLubyte **)malloc(6 * sizeof(GLubyte*));
        NSAssert(self.data != NULL, @"ERROR: failed to allocate image cube map data buffer");

        for (int i=0; i<6; ++i) {
            self.data[i] = (GLubyte *)malloc(self.size);
            NSAssert(self.data != NULL, @"ERROR: failed to allocate storage for image cube map data buffer");
        }
    }

    memcpy(self.data[faceIndex], pData, self.size);
}

@end


@interface NFRDataMap()
@property (nonatomic, assign, readwrite) GLsizei size;
@property (nonatomic, assign, readwrite) GLuint rowByteSize;
@property (nonatomic, assign, readwrite) GLubyte *data;
@end

@implementation NFRDataMap

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
    if (self.data != NULL) {
        free(self.data);
    }
}

- (void) loadWithData:(GLubyte *)pData ofSize:(CGRect)rect ofType:(GLenum)type withFormat:(GLenum)format {
    self.width = CGRectGetWidth(rect);
    self.height = CGRectGetHeight(rect);
    self.format = format;
    self.type = type;

    //
    // TODO: add support for additional types and formats
    //

    NSInteger typeSize = 0;
    switch (type) {
        case GL_UNSIGNED_BYTE:
            typeSize = sizeof(GLubyte);
            break;

        default:
            NSAssert(nil, @"ERROR: NFDataMap can NOT load data with an unknown type");
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
            NSAssert(nil, @"ERROR: NFDataMap can NOT load data with an unknown format");
            break;
    }

    self.rowByteSize = rect.size.width * typeSize * componentsPerElt;
    self.size = rect.size.height * self.rowByteSize;

    //
    // TODO: be smarter about memory, don't free if the sizes are the same
    //
    if (self.data != NULL) {
        free(self.data);
    }

    GLubyte *pDataCopy = (GLubyte *)malloc(self.size);
    NSAssert(pDataCopy != NULL, @"ERROR: failed to allocate image data buffer");

    memcpy(pDataCopy, pData, [self size]);
    self.data = pDataCopy;
}

@end



@interface NFRDataSampler()
// private properties
@end

@implementation NFRDataSampler
@end
