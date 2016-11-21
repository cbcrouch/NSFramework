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
        NSLog(@"ERROR: write returned error: %@", [error localizedDescription]);
    }

    // reopen file to start appending data
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingToURL:url error:&error];
    NSAssert(fileHandle != nil, @"Failed to open %@", filePath);

    // seek to start of the file
    [fileHandle seekToFileOffset:0];



    char bytes[32] = "#\n# NSData TEST.obj\n#\n\0";

    // will this make a duplicate copy of the C string ??
    //NSString* string = [[NSString alloc] initWithCString:bytes encoding:NSUTF8StringEncoding]];

    //NSMutableData* data = [NSMutableData data];
    //[data appendData:[@"NSString" dataUsingEncoding:NSUTF8StringEncoding]];


    // will this make a duplicate of the C string ??
    NSData* fileData = [NSData dataWithBytes:bytes length:strlen(bytes)];


    [fileHandle writeData:fileData];

    // subsequent writes will be appended to the file
    //[fileHandle writeData:fileData];

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
