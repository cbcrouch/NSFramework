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

    //
    // TODO: implement
    //


    // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Strings/Articles/readingFiles.html

    // http://stackoverflow.com/questions/17779655/objective-c-create-text-file-to-read-and-write-line-by-line-in-cocoa


    NSURL* url = [NSURL fileURLWithPath:filePath isDirectory:NO];
    NSString* string = @"#\n# TEST.obj\n#\n";
    NSError *error;

    //
    // TODO: use UTF-8 encoding if possible, verify what other obj files are using
    //
    // http://www.cocoabuilder.com/archive/cocoa/114751-utf8-vs-unicode-encodings.html

    // NOTE: probably doesn't need to be atomically done at all
    BOOL ok = [string writeToURL:url atomically:YES encoding:NSUnicodeStringEncoding error:&error];

    if(!ok) {
        NSLog(@"ERROR: there was an error while attempting to write file out");
        NSLog(@"Write returned error: %@", [error localizedDescription]);
    }



    // https://developer.apple.com/reference/foundation/nsdata
    // https://developer.apple.com/reference/foundation/nsdata/1415134-writetourl?language=objc

    // http://stackoverflow.com/questions/16224389/example-for-file-read-write-with-nsfilehandle


    //
    // TODO: would need to create the file first if using the NSData method (this method will be useful for writing
    //       out raw bytes for image data)
    //

/*
    //
    // TODO: use this call instead
    //
    //NSFileHandle* fileHandle = NSFileHandle fileHandleForWritingToURL:<#(nonnull NSURL *)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>;

    NSFileHandle *fileHandle;
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    NSAssert(fileHandle != nil, @"Failed to open %@", filePath);


    //
    // TODO: need to figure out how to set encoding i.e. convert these ASCII bytes to UTF8
    //       NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; is one option
    //
    char bytes[32] = "#\n#NSData TEST.obj\n#\n";

    //
    // TODO: seems like the file is being encoded in UTF-16
    //
    NSData* fileData;
    fileData = [NSData dataWithBytes:bytes length:sizeof(bytes)];


    [fileHandle writeData:fileData];
    [fileHandle closeFile];
*/



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
