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
    // vertex data
    //
    NFRGeometry* geometry = assetData.geometry;
    NFRBuffer* vertexBuffer = geometry.vertexBuffer;
    switch (vertexBuffer.bufferDataType) {
        case kBufferDataTypeNFVertex_t: {
            NFVertex_t* pVertices = (NFVertex_t*)vertexBuffer.bufferDataPointer;
            size_t numVertices = vertexBuffer.bufferDataSize / sizeof(NFVertex_t);

            //
            // TODO: should modify processing and rendering to not duplicate vertices, this will most
            //       likely require some modifications or corrections to the indexing
            //

            // collect unique vertices vertices
            NSMutableArray* uniqueVertices = [[NSMutableArray alloc] init];
            for (size_t i=0; i<numVertices; ++i) {
                // store vertices in an array and on each iteration check if it is a duplicate
                BOOL addVertex = YES;
                for(NSValue* value in uniqueVertices) {
                    NFVertex_t vertex;
                    [value getValue:&vertex];
                    if (vertex.pos[0] == pVertices->pos[0] && vertex.pos[1] == pVertices->pos[1] && vertex.pos[2] == pVertices->pos[2]) {
                        addVertex = NO;
                        break;
                    }
                }

                if (addVertex) {
                    [uniqueVertices addObject:[NSValue valueWithBytes:pVertices objCType:@encode(NFVertex_t)]];
                }

                ++pVertices;
            }

            for (NSValue* value in uniqueVertices) {
                NFVertex_t vertex;
                [value getValue:&vertex];

                // most all files seem to use 6 digits of precision
                rv = snprintf(bytes, sizeof(bytes), "v %6.6f %6.6f %6.6f\n", vertex.pos[0], vertex.pos[1], vertex.pos[2]);
                NSAssert(rv > 0, @"ERROR: sprintf failed");
                writeLine(bytes);
            }
        } break;

        case kBufferDataTypeNFDebugVertex_t:
            NSLog(@"WARNING: writeAsset doesn't yet support debug vertex format");
            break;

        default:
            NSLog(@"WARNING: writeAsset attempted to write out vertex data of an unsupported type");
            break;
    }



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
