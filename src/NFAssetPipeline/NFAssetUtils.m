//
//  NFAssetUtils.m
//  NSFramework
//
//  Created by cbcrouch on 2/26/15.
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import "NFAssetUtils.h"

@implementation NFAssetUtils

+ (NFFace_t) calculateFaceWithPoints:(NFVertex_t *)vertices withIndices:(GLushort [3])indices {
    NFFace_t face;
    NSInteger p1, p2, p3;

    p1 = indices[0];
    p2 = indices[1];
    p3 = indices[2];

    face.indices[0] = indices[0];
    face.indices[1] = indices[1];
    face.indices[2] = indices[2];

    // for a triangle with points p1, p2, p3

    // U = p2 - p1
    // V = p3 - p1
    // N = U X V

    // manually calculated cross product
    // Nx = UyVz - UzVy
    // Ny = UzVx - UxVz
    // Nz = UxVy - UyVx

    GLKVector4 v1 = GLKVector4Make(vertices[p1].pos[0], vertices[p1].pos[1], vertices[p1].pos[2], vertices[p1].pos[3]);
    GLKVector4 v2 = GLKVector4Make(vertices[p2].pos[0], vertices[p2].pos[1], vertices[p2].pos[2], vertices[p2].pos[3]);
    GLKVector4 v3 = GLKVector4Make(vertices[p3].pos[0], vertices[p3].pos[1], vertices[p3].pos[2], vertices[p3].pos[3]);

    GLKVector4 U = GLKVector4Subtract(v2, v1);
    GLKVector4 V = GLKVector4Subtract(v3, v1);
    GLKVector4 N = GLKVector4CrossProduct(U, V);

    N = GLKVector4Normalize(N);

    face.normal[0] = N.x;
    face.normal[1] = N.y;
    face.normal[2] = N.z;
    face.normal[3] = N.w;

    // length between two 3d points
    // xd = x2 - x1
    // yd = y2 - y1
    // zd = z2 - z1
    // d = sqrt(xd^2 + yd^2 + zd^2)

    GLKVector4 vd = GLKVector4Subtract(v2, v1);
    float a = sqrtf(powf(vd.x, 2) + powf(vd.y, 2) + powf(vd.z, 2));

    vd = GLKVector4Subtract(v3, v1);
    float b = sqrtf(powf(vd.x, 2) + powf(vd.y, 2) + powf(vd.z, 2));

    vd = GLKVector4Subtract(v3, v2);
    float c = sqrtf(powf(vd.x, 2) + powf(vd.y, 2) + powf(vd.z, 2));

    // Heron's Formula (triangle surface area):
    // a, b, and c are the lengths of the triangle sides
    // s = (a + b + c)/2.0
    // A = sqrt(s(s-a)(s-b)(s-c))

    float s = (a + b + c) / 2.0f;
    face.area = sqrtf(s*(s-a)*(s-b)*(s-c));

    return face;
}

+ (GLKVector4) calculateAreaWeightedNormalOfIndex:(GLushort)index withFaces:(NSArray *)faceArray {
    GLKVector4 vector;
    memset(&vector, 0x00, sizeof(GLKVector4));

    NFFace_t encodedFace;
    GLKVector4 normal;
    for (id obj in faceArray) {
        NSValue *value = obj;
        [value getValue:&encodedFace];

        if (encodedFace.indices[0] == index || encodedFace.indices[1] == index || encodedFace.indices[2] == index) {
            for (int i=0; i<4; ++i) {
                normal.v[i] = encodedFace.normal[i];
            }
            normal = GLKVector4MultiplyScalar(normal, encodedFace.area);
            vector = GLKVector4Add(vector, normal);
        }
    }

    vector = GLKVector4Normalize(vector);
    return vector;
}

+ (GLKVector4) calculateAngleWeightedNormalOfVertex:(GLfloat[4])vertex withFaces:(NSArray *)faceArray {

    NSAssert(nil, @"ERROR: this function is NOT implemented, yet...");

    GLKVector4 vector;
    memset(&vector, 0x00, sizeof(GLKVector4));

    //
    // TODO: should only use this method when vertex and faces are contained within a smoothing group
    //

    // cos(theta) = A dot B if A and B have been normalized

    // A dot B is then bound between [-1 1] at which point would then have to get the angle based on that or
    // could the weighting scaling be performed with just that bound ??

    // 1 means that vectors lie in the same direction
    // -1 means that vectors lie in opposite direction
    // 0 means they are 90 degress apart


    NFFace_t encodedFace;
    //GLKVector4 normal;
    for (id obj in faceArray) {
        NSValue *value = obj;
        [value getValue:&encodedFace];

        //
        // TODO: check if vertex provided is contained within the face
        //
    }
    
    vector = GLKVector4Normalize(vector);
    return vector;
}

+ (NFRDataMap *) parseTextureFile:(NSString *)file flipVertical:(BOOL)flip {
    // NOTE: not using the GLK texture loader class since I want to store the texture in both
    //       my own OpenGL specific format and as an NSImage for displaying in a utility window

    NSImage *nsimage = [[NSImage alloc] initWithContentsOfFile:file];

    //
    // TODO: switch off the file name extension to use the correct representation when loading
    //       the NSBitmapImage object
    //
    // use NSImage NSBitmapImageRep to load TIFF, BMP, JPEG, GIF, PNG, DIB, ICO
    // to get a complete list of all supported image formats use the NSImage method imageFileTypes
    NSBitmapImageRep *imageClass = [[NSBitmapImageRep alloc] initWithData:nsimage.TIFFRepresentation];

    CGImageRef cgImage = imageClass.CGImage;
    NSAssert(cgImage != NULL, @"ERROR: NSBitmapImageRep has a NULL CGImage");

    CGRect mapSize = CGRectMake(0.0, 0.0, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
    size_t rowByteSize = CGImageGetBytesPerRow(cgImage);

    //
    // TODO: remove all OpenGL dependencies from asset parsing/processing by defining common data types
    //
    GLenum format = GL_INVALID_ENUM;
    GLenum type = GL_INVALID_ENUM;

    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    //size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage); // not currently needed

    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
    CGColorSpaceModel colorModel = CGColorSpaceGetModel(colorSpace);
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaNone;
    if (colorModel == kCGColorSpaceModelRGB) {
        if (imageClass.alpha) {
            //format = GL_RGBA;

            bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
        }
        else {
            //format = GL_RGB;

            // NOTE: as stated by the Apple developer docs for the CGBitmapContextCreate function
            // "The constants for specifying the alpha channel information are declared with the CGImageAlphaInfo type but can be passed to this parameter safely."
            bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipLast;

            NSAssert(bitsPerComponent == 8, @"ERROR: RGB images currently only support 8 bits per component");
            rowByteSize = CGRectGetWidth(mapSize) * 4;
        }
    }
    else {
        NSAssert(nil, @"ERROR: unsupported color model");
    }

    // check if sample size is the same as unsigned byte size
    if (imageClass.bitsPerSample / CHAR_BIT == sizeof(GLubyte)) {
        type = GL_UNSIGNED_BYTE;
    }
    else {
        NSAssert(nil, @"ERROR: unsupported sample type");
    }

    GLubyte *pData = (GLubyte *)malloc(mapSize.size.height * rowByteSize);
    NSAssert(pData != NULL, @"ERROR: failed to allocate image data buffer");

    CGContextRef context = CGBitmapContextCreate(pData, CGRectGetWidth(mapSize), CGRectGetHeight(mapSize),
                                                 bitsPerComponent, rowByteSize, CGImageGetColorSpace(cgImage),
                                                 bitmapInfo);

    CGContextSetBlendMode(context, kCGBlendModeCopy);
    if (flip) {
        CGContextTranslateCTM(context, 0.0, CGRectGetHeight(mapSize));
        CGContextScaleCTM(context, 1.0, -1.0);
    }
    // copy cgImage into the image data buffer provided in the CG context
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, CGRectGetWidth(mapSize), CGRectGetHeight(mapSize)), cgImage);
    CGContextRelease(context);

    //
    // TODO: CGImage conversion code (appears) to be converting RGB to RGBA, need to make this configurable
    //
    format = GL_RGBA;

#if 0
    int winStyleMask = NSTitledWindowMask | NSClosableWindowMask;
    // NSMiniaturizableWindowMask | NSResizableWindowMask
    // NSTexturedBackgroundWindowMask
    // NSBorderlessWindowMask // use to make it a splash screen

    CGRect imageRect = CGRectMake(0, 0, [nsimage size].width, [nsimage size].height);

    NSWindow *imageWindow = [[NSWindow alloc] initWithContentRect:imageRect
                                                        styleMask:winStyleMask
                                                          backing:NSBackingStoreBuffered
                                                            defer:NO];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:imageRect];

    [imageView setImage:nsimage];
    [imageView setBounds:imageRect];
    [[imageWindow contentView] addSubview:imageView];

    [imageWindow setHasShadow:YES];
    [imageWindow center];
    [imageWindow makeKeyAndOrderFront:self]; // will issue a dispaly call to all sub views
    //[imageView display]; // explicit call not currently needed but may be in future versions of OS X

#endif


    NFRDataMap *dataMap = [[NFRDataMap alloc] init];
    [dataMap loadWithData:pData ofSize:mapSize ofType:type withFormat:format];

    NSAssert(pData != NULL, @"ERROR: image data buffer pointer was set to NULL prior to freeing memory");
    free(pData);
    
    return dataMap;
}

@end
