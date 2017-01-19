//
//  NFAssetData+Wavefront.m
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#import "NFAssetData+Wavefront.h"

@implementation NFAssetData (Wavefront)

- (void) setNumberOfSubsets:(NSInteger)numSubsets {
    // build subset array
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:numSubsets];

    NFAssetSubset *subset;
    for (int i=0; i<numSubsets; ++i) {
        subset = [[NFAssetSubset alloc] init];
        [tempArray addObject:subset];
    }

    // set the non-mutable asset data subset array
    self.subsetArray = [tempArray copy]; // will return nil if tempArray is nil
    //self.subsetArray = [NSArray arrayWithArray:tempArray]; // will return @[] (empty array) if tempArray is nil

    // NOTE: if copy fits the design better than arrayWithArray then perhaps use the copy
    //       qualifier for the subsetArray property
}

- (void) addSubsetWithIndices:(NSMutableArray *)indices ofObject:(WFObject *)wfObj atIndex:(NSUInteger)idx {
    NFAssetSubset *subset = (self.subsetArray)[idx];


    
    //
    // TODO: check the face indices against the obj files
    //

#if 0
    for(int i=0; i<indices.count; i+=3) {
        NSString* str = [indices objectAtIndex:i];
        fprintf(stdout, "%s ", str.UTF8String);

        str = [indices objectAtIndex:i+1];
        fprintf(stdout, "%s ", str.UTF8String);

        str = [indices objectAtIndex:i+2];
        fprintf(stdout, "%s\n", str.UTF8String);
    }
#endif


#if 0
    fprintf(stdout, "positions\n");
    for (NSValue* value in wfObj.vertices) {
        GLKVector3 vertex;
        [value getValue:&vertex];
        fprintf(stdout, "\t%f, %f, %f\n", vertex.x, vertex.y, vertex.z);
    }

    fprintf(stdout, "tex coords\n");
    for (NSValue* value in wfObj.textureCoords) {
        GLKVector3 texCoord;
        [value getValue:&texCoord];
        fprintf(stdout, "\t%f, %f\n", texCoord.s, texCoord.t);
    }

    fprintf(stdout, "normals\n");
    for (NSValue* value in wfObj.normals) {
        GLKVector3 normal;
        [value getValue:&normal];
        fprintf(stdout, "\t%f, %f, %f\n", normal.x, normal.y, normal.z);
    }
#endif

    

    // get number of unique vertices to determine the correct number to allocate
    NSMutableArray *uniqueArray = [[NSMutableArray alloc] init];
    [uniqueArray addObjectsFromArray:[NSSet setWithArray:indices].allObjects]; // remove duplicates

    //
    // TODO: try using a mutable array instead of pre-allocating to very numbers
    //
    NFVertex_t *pData = (NFVertex_t *)malloc(uniqueArray.count * sizeof(NFVertex_t));
    GLushort *pIndices = (GLushort *)malloc(indices.count * sizeof(GLushort));
    memset(pData, 0x00, [uniqueArray count] * sizeof(NFVertex_t));
    memset(pIndices, 0x00, [indices count] * sizeof(GLushort));


    NSUInteger dataIndex = 0;
    NSMutableArray *indexArray = [[NSMutableArray alloc] initWithCapacity:uniqueArray.count];

    for (NSString *faceStr in uniqueArray) {
        NSInteger vertIndex = -1;
        NSInteger texIndex = -1;
        NSInteger normIndex = -1;
        NSArray *groupParts = [faceStr componentsSeparatedByString:@"/"];

        // face indices are grouped as vertex/texture-coord/normal
        //f v1/vt1/vn1 v2/vt2/vn2 v3/vt3/vn3

        // normals are optional, faces can also be quads
        //f v1/vt1 v2/vt2 v3/vt3 v4/vt4

        // texture coordinates are also optional
        //f v1//vn1 v2//vn2 v3//vn3

        //
        // TODO: should see if vertices themselves are optional i.e. if a file only has NURBS data
        //       does it need to contain faces for the indexes or are they generated from the NURBS ??
        //

        // NOTE: indices in file start at 1, need to make zero based and if you ever see a negative face index
        //       it means go back that many vertices i.e. -8 means go back 8 vertices from the last one read

        // NOTE: this will only work if all the faces are listed after the vertices they reference
        //       (is this guaranteed by the WavefrontObj file format ?? )

        NSUInteger count = groupParts.count;
        NSInteger intValue;
        for (NSUInteger i=0; i<count; ++i) {
            // NOTE: will have an empty string i.e. "" at the texture coordinate or normal position when
            //       there is no texture coordinate given and this will return an intValue of 0
            intValue = [groupParts[i] intValue];
            switch (i) {
                case kGroupIndexVertex: vertIndex = normalizeObjIndex(intValue, wfObj.vertices.count); break;
                case kGroupIndexTex: texIndex = normalizeObjIndex(intValue, wfObj.textureCoords.count); break;
                case kGroupIndexNorm: normIndex = normalizeObjIndex(intValue, wfObj.normals.count); break;
                default: NSAssert(nil, @"Error, unknown face index type"); break;
            }
        }

        NSValue *valueObj;

        // NOTE: w component of norm should be 0.0, and 1.0 for position (for vectors w = 0.0 and for points w = 1.0)

        if (vertIndex != -1) {
            GLKVector3 vertex;
            valueObj = wfObj.vertices[vertIndex];
            [valueObj getValue:&vertex];
            pData[dataIndex].pos[0] = vertex.x;
            pData[dataIndex].pos[1] = vertex.y;
            pData[dataIndex].pos[2] = vertex.z;
            pData[dataIndex].pos[3] = 1.0f;
        }

        if (texIndex != -1) {
            GLKVector3 texCoord;
            valueObj = wfObj.textureCoords[texIndex];
            [valueObj getValue:&texCoord];
            pData[dataIndex].texCoord[0] = texCoord.s;
            pData[dataIndex].texCoord[1] = texCoord.t;
            pData[dataIndex].texCoord[2] = texCoord.p;
        }

        if (normIndex != -1) {
            GLKVector3 normal;
            valueObj = wfObj.normals[normIndex];
            [valueObj getValue:&normal];
            pData[dataIndex].norm[0] = normal.x;
            pData[dataIndex].norm[1] = normal.y;
            pData[dataIndex].norm[2] = normal.z;
            pData[dataIndex].norm[3] = 0.0f;
        }


        //
        // TODO: it appears that way too many vertices are being created for anything other than cube.obj
        //
#if 0
        fprintf(stdout, "index: %ld\n", dataIndex);
        fprintf(stdout, "\tnorm: (%f, %f, %f)\n",
            pData[dataIndex].norm[0],
            pData[dataIndex].norm[1],
            pData[dataIndex].norm[2]);
        fprintf(stdout, "\ttexc: (%f, %f)\n",
            pData[dataIndex].texCoord[0],
            pData[dataIndex].texCoord[1]);
        fprintf(stdout, "\tvert: (%f, %f, %f)\n",
            pData[dataIndex].pos[0],
            pData[dataIndex].pos[1],
            pData[dataIndex].pos[2]);
#endif


        // record data index to be associated with specific Wavefront obj face value
        [indexArray addObject:@(dataIndex)];
        ++dataIndex;
    }



    //
    // TODO: this indexing may be what is screwed up
    //

    //NSLog(@"indexArray.count %ld", indexArray.count);
    //NSLog(@"uniqueArray.count %ld", uniqueArray.count);


    // build a dictionary of which face string corresponds with which vertex using the uniqueArray
    // (should also investigate using an NSMapTable or CFDictionary)

    NSDictionary *indexDict = [NSDictionary dictionaryWithObjects:indexArray forKeys:uniqueArray];



    // iterate through faceStrArray and set index value based on dictionary lookup
    dataIndex = 0;
    for (NSString *faceStr in indices) {
        NSNumber *indexNum = indexDict[faceStr];
        pIndices[dataIndex] = (GLushort)indexNum.intValue;

        //
        // TODO: the indices need to be modified, the way they are currently being built isn't great
        //
        //fprintf(stdout, "%d\n", pIndices[dataIndex]);

        ++dataIndex;
    }


    // allocate and load vertex/index data into the subset
    [subset allocateIndicesWithNumElts:indices.count];
    [subset loadIndexData:pIndices ofSize:indices.count * sizeof(GLushort)];

    [subset allocateVerticesOfType:kVertexFormatDefault withNumVertices:uniqueArray.count];
    [subset loadVertexData:pData ofType:kVertexFormatDefault withNumVertices:uniqueArray.count];

    free(pData);
    free(pIndices);
}

@end
