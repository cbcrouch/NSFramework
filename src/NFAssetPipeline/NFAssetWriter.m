//
//  NFAssetWriter.m
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import "NFAssetWriter.h"

#define MAX_LINE_LENGTH 128

//
// TODO: after this is complete generate a shadow test scene and save out to file
//

@implementation NFAssetWriter

+ (void) writeAsset:(NFAssetData *)assetData toFile:(NSString *)filePath withFormat:(ASSET_FORMAT)format {
    // create an empty UTF-8 file
    NSError *error;
    NSURL* url = [NSURL fileURLWithPath:filePath isDirectory:NO];
    if(![@"" writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        NSLog(@"ERROR: write returned error: %@", error.localizedDescription);
    }

    // reopen file to start appending data and seek to start
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingToURL:url error:&error];
    NSAssert(fileHandle != nil, @"Failed to open %@", filePath);
    [fileHandle seekToFileOffset:0];

    char bytes[MAX_LINE_LENGTH] = {};
    void (^writeLine)(void*) = ^ void (void* bytes) {
        NSData* testData = [NSData dataWithBytesNoCopy:bytes length:strlen(bytes) freeWhenDone:NO];
        // subsequent writes will be appended to the file
        [fileHandle writeData:testData];
    };

    //
    // TODO: check length of file name to ensure that it will fit
    //
    const char* fileName = filePath.lastPathComponent.UTF8String;
    // NOTE: sprintf function will add a \0 at the end of the string
    int rv = snprintf(bytes, sizeof(bytes), "#\n# %s\n#\n\n", fileName);
    NSAssert(rv > 0, @"ERROR: sprintf failed");
    writeLine(bytes);

    //
    // TODO: implement writing out material file
    //
    rv = snprintf(bytes, sizeof(bytes), "%s\n\n", "mtllib default.mtl");
    NSAssert(rv > 0, @"ERROR: sprintf failed");
    writeLine(bytes);

    const char* objectName = filePath.lastPathComponent.stringByDeletingPathExtension.UTF8String;
    rv = snprintf(bytes, sizeof(bytes), "o %s\n\n", objectName);
    NSAssert(rv > 0, @"ERROR: sprintf failed");
    writeLine(bytes);


    //
    // TODO: start writing out vertex data
    //
/*
    NFRGeometry* geometry = assetData.geometry;
    NFRBuffer* vertexBuffer = geometry.vertexBuffer;

    //
    // TODO: get vertex pointer, and use type and size to determine where the values are stored
    //       and how many of them there are
    //
    //vertexBuffer.bufferDataPointer
    //vertexBuffer.bufferDataType
    //vertexBuffer.bufferDataSize

    // most all files seem to use 6 digits of precision
    rv = snprintf(bytes, sizeof(bytes), "v %6.6f %6.6f %6.6f\n", 0.0f, 0.0f, 0.0f);
    NSAssert(rv > 0, @"ERROR: sprintf failed");
    writeLine(bytes);
*/

    [fileHandle closeFile];


    //
    // TODO: follow basic format
    //

    //
    // TODO: some obj files interleave v, vt, vn (should consider supporting it as an option)
    //
    // v 0.0 0.0 0.0
    // vt
    // vn


    // g -> group
    // usemtl FILE_NAME   // can also be usemtl (null) for no material
    // f

    // g
    // f

    // TODO: enforce max supported vertices of 9,999,999

    // NOTE: f indices look to be one based..
    // f 1469978/1469985/1469978 1469984/1469985/1469984 1469985/1469985/1469985   // 74 characters (w/o \n\0)




    // NOTE: Wavefront obj vertices are stored in a right-handed coordinate system
    //       (currently using right-handed coordinate system already)


    //
    // TODO: is the geometry objects getting duplicated ??
    //

    //NSArray* array = assetData.subsetArray;

    //NFAssetData* subset;

    //subset.geometry
    //subset.surfaceModelArray



    //NFRGeometry* geometry = assetData.geometry;

    //geometry.indexBuffer
    //geometry.vertexBuffer

    //geometry.surfaceModel
    //geometry.textureDictionary


}

@end
