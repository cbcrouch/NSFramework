//
//  NFAssetWriter.m
//  NSFramework
//
//  Copyright © 2016 Casey Crouch. All rights reserved.
//

#import "NFAssetWriter.h"

#define MAX_LINE_LENGTH 128


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

    NSMutableArray* uniqueVertices = [[NSMutableArray alloc] init];
    NSMutableArray* uniqueTexCoords = [[NSMutableArray alloc] init];
    NSMutableArray* uniqueNormals = [[NSMutableArray alloc] init];

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
            // NOTE: vertices are duplicated because they are interleaved with texture coordinates and
            //       the vertex normal, since Wavefront obj files store these three vertex attributes
            //       separately they must be broken out and de-duplicated
            //

            // collect unique vertices vertices
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

            //
            // write out vertex texture coordinates
            //

            // reset vertex pointer and add another line to seperate from vertex positions
            pVertices = (NFVertex_t*)vertexBuffer.bufferDataPointer;
            rv = snprintf(bytes, sizeof(bytes), "\n");
            NSAssert(rv > 0, @"ERROR: sprintf failed");
            writeLine(bytes);

            // collect unique tex coords
            for (size_t i=0; i<numVertices; ++i) {
                BOOL addVertex = YES;
                for (NSValue* value in uniqueTexCoords) {
                    NFVertex_t vertex;
                    [value getValue:&vertex];
                    if (vertex.texCoord[0] == pVertices->texCoord[0] && vertex.texCoord[1] == pVertices->texCoord[1]) {
                        addVertex = NO;
                        break;
                    }
                }

                if (addVertex) {
                    [uniqueTexCoords addObject:[NSValue valueWithBytes:pVertices objCType:@encode(NFVertex_t)]];
                }

                ++pVertices;
            }

            for (NSValue* value in uniqueTexCoords) {
                NFVertex_t vertex;
                [value getValue:&vertex];

                rv = snprintf(bytes, sizeof(bytes), "vt %6.6f %6.6f\n", vertex.texCoord[0], vertex.texCoord[1]);
                NSAssert(rv > 0, @"ERROR: sprintf failed");
                writeLine(bytes);
            }

            //
            // write out vertex normals
            //

            // reset vertex pointer and add another line to seperate from texture coordinates
            pVertices = (NFVertex_t*)vertexBuffer.bufferDataPointer;
            rv = snprintf(bytes, sizeof(bytes), "\n");
            NSAssert(rv > 0, @"ERROR: sprintf failed");
            writeLine(bytes);

            // collect unique normals
            for (size_t i=0; i<numVertices; ++i) {
                BOOL addVertex = YES;
                for (NSValue* value in uniqueNormals) {
                    NFVertex_t vertex;
                    [value getValue:&vertex];
                    if (vertex.norm[0] == pVertices->norm[0] && vertex.norm[1] == pVertices->norm[1] && vertex.norm[2] == pVertices->norm[2]) {
                        addVertex = NO;
                        break;
                    }
                }

                if (addVertex) {
                    [uniqueNormals addObject:[NSValue valueWithBytes:pVertices objCType:@encode(NFVertex_t)]];
                }

                ++pVertices;
            }

            for (NSValue* value in uniqueNormals) {
                NFVertex_t vertex;
                [value getValue:&vertex];

                // most all files seem to use 6 digits of precision
                rv = snprintf(bytes, sizeof(bytes), "vn %6.6f %6.6f %6.6f\n", vertex.norm[0], vertex.norm[1], vertex.norm[2]);
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


    //
    // TODO: write out correct material file for group and give the group a name
    //
    rv = snprintf(bytes, sizeof(bytes), "\ng group_1\nusemtl default.mtl\n\n");
    NSAssert(rv > 0, @"ERROR: sprintf failed");
    writeLine(bytes);


    //
    // TODO: write out indices, will need access to the unique arrays
    //

    NFRBuffer* indexBuffer = geometry.indexBuffer;
    NSAssert(indexBuffer.bufferDataType == kBufferDataTypeUShort, @"ERROR: index buffer is not of type ushort");

    NSAssert(sizeof(GLushort) == sizeof(unsigned short), @"ERROR: GLushort is not the same size as unsigned short");

    NFVertex_t* pVertices = (NFVertex_t*)vertexBuffer.bufferDataPointer;
    unsigned short* pIndices = indexBuffer.bufferDataPointer;
    size_t numIndices = indexBuffer.bufferDataSize / sizeof(unsigned short);

    for (size_t i=0; i<numIndices; ++i) {

        //
        // TODO: enforce max supported vertices of 9,999,999 and modify indices to be one based
        //

        //
        // TODO: lookup NFVertex_t in vertexBuffer.bufferDataPointer then find cooresponding values in
        //       the unique arrays and then write the unique arrays index out for the face index values
        //       (and +1 the values since Wavefront obj indices are 1 based)
        //

        int index = 0;
        NFVertex_t vertex = pVertices[*pIndices];
        for (NSValue* value in uniqueVertices) {
            NFVertex_t v;
            [value getValue:&v];
            if (vertex.pos[0] == v.pos[0] && vertex.pos[1] == v.pos[1] && vertex.pos[2] == v.pos[2]) {

                //
                // TODO: found matching index in unique vertices
                //

                break;
            }
            ++index;
        }


        // f v0/vt0/vn0 v0/vt0/vn0 v0/vt0/vn0


        rv = snprintf(bytes, sizeof(bytes), "f %d\n", *pIndices);
        NSAssert(rv > 0, @"ERROR: sprintf failed");
        writeLine(bytes);

        ++pIndices;
    }


    [fileHandle closeFile];
}

@end
