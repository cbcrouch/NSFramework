//
//  NFAssetWriter.m
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import "NFAssetWriter.h"

@implementation NFAssetWriter


//
// TODO: after this is complete generate a shadow test scene and save out to file
//

+ (void) writeAsset:(NFAssetData *)assetData toFile:(NSString *)filePath withFormat:(ASSET_FORMAT)format {
    // create an empty UTF-8 file
    NSError *error;
    NSURL* url = [NSURL fileURLWithPath:filePath isDirectory:NO];
    if(![@"" writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        NSLog(@"ERROR: write returned error: %@", error.localizedDescription);
    }

    // reopen file to start appending data
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingToURL:url error:&error];
    NSAssert(fileHandle != nil, @"Failed to open %@", filePath);

    // seek to start of the file
    [fileHandle seekToFileOffset:0];


    //
    // TODO: should probably decide on a hard limit for the number of float digits to support
    //
    //int max_digits = 3 + FLT_MANT_DIG - FLT_MIN_EXP; // 3 => "-0."


    //
    // TODO: determine the max line length to use
    //
    char bytes[128] = {};


    NSMutableData* data = [NSMutableData data];

    void (^writeLine)(NSMutableData*, void*) = ^ void (NSMutableData* data, void* bytes) {
        NSRange range;
        range.location = 0;
        range.length = strlen(bytes);
        [data replaceBytesInRange:range withBytes:bytes];
        //
        // TODO: add some exception handling for file based operations
        //
        [fileHandle writeData:data];
    };

    //
    // TODO: check length of file name to ensure that it will fit
    //
    const char* fileName = filePath.lastPathComponent.UTF8String;
    // NOTE: sprintf function will add a \0 at the end of the string
    int rv = snprintf(bytes, sizeof(bytes), "%s%s%s", "#\n# ", fileName, "\n#\n\n");
    NSAssert(rv > 0, @"ERROR: sprintf failed");
    writeLine(data, bytes);


    // subsequent writes will be appended to the file


    [fileHandle closeFile];


    //
    // TODO: follow basic format
    //

    // o -> object name
    // mtllib FILE_NAME.ext

    // v
    // vt
    // vn

    // NOTE: f indices look to be one based..

    // g -> group
    // usemtl FILE_NAME   // can also be usemtl (null) for no material
    // f

    // g
    // f

    // ...



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
