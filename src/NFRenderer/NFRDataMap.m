//
//  NFRDataMap.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFRDataMap.h"

#define GL_DO_NOT_WARN_IF_MULTI_GL_VERSION_HEADERS_INCLUDED
#import <OpenGL/gl3.h>

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



@interface NFRDataSampler()
// private properties
@end

@implementation NFRDataSampler
@end
