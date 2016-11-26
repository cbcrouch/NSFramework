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
    // TODO: determine the max line length
    //
    char bytes[32] = {};

    sprintf(bytes, "%s%s%s", "#\n# ", filePath.lastPathComponent.UTF8String, "\n#\n\n\0");


    // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/BinaryData/Tasks/WorkingMutableData.html


    //
    // TODO: use mutable bytes with a fixed length (same size as bytes) and reuse per line to avoid making
    //       an excessive number of allocations
    //

    NSRange range;
    NSMutableData* data = [NSMutableData data];

    range.location = 0;
    range.length = strlen(bytes);

    //
    // TODO: which replaceBytes method is safer / more stable ??
    //
    [data replaceBytesInRange:range withBytes:bytes];
    //[data replaceBytesInRange:range withBytes:bytes length:strlen(bytes)];


    //NSData* fileData = [NSData dataWithBytesNoCopy:bytes length:strlen(bytes) freeWhenDone:NO];
    //[fileHandle writeData:fileData];


    // subsequent writes will be appended to the file
    [fileHandle writeData:data];


    [fileHandle closeFile];


    //
    // TODO: follow basic format
    //

    // o -> object name
    // mtllib FILE_NAME.ext

    // v
    // vt
    // vn

    // NOTE: f indices may be one based.. 

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
